# == Schema Information
# Schema version: 20110630143837
#
# Table name: suite_executions
#
#  id                 :integer(4)      not null, primary key
#  suite_id           :integer(4)
#  user_id            :integer(4)
#  suite_container_id :integer(4)
#  identifier         :string(50)      default(" ")
#  project_id         :integer(4)
#  time_spent         :integer(4)      default(0)
#  status             :integer(4)      default(0)
#  created_at         :datetime
#  updated_at         :datetime
#

 #
 #  @Authors:    
 #      Brizuela Lucia                  lula.brizuela@gmail.com
 #      Guerra Brenda                   brenda.guerra.7@gmail.com
 #      Crosa Fernando                  fernandocrosa@hotmail.com
 #      Branciforte Horacio             horaciob@gmail.com
 #      Luna Juan                       juancluna@gmail.com
 #      
 #  @copyright (C) 2010 MercadoLibre S.R.L
 #
 #
 #  @license        GNU/GPL, see license.txt
 #  This program is free software: you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation, either version 3 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program.  If not, see http://www.gnu.org/licenses/.
 #
require "socket"

class SuiteExecution < ActiveRecord::Base
  belongs_to :suite
  belongs_to :user
  belongs_to :suite_container
  belongs_to :project
  has_many :executions, :dependent => :destroy
  has_many :execution_configuration_values, :dependent => :destroy
  
  validates_presence_of :suite_id, :message => _("Must Select any Suite")
  validates_presence_of :project_id, :message => _("Must Select any Project")
  validates_presence_of :user_id, :message => _("Must Complete User Field")
  validates_length_of :identifier,:maximum=>50, :allow_nil => true, :message => _("Enter less than 50 characters for the identifier")
  
  # TODO: move this to a Module for integration with Execution
  STATUS = %w(waiting running ok error commented not_run stopped complete)
  
  STATUS.each_with_index do |s, i|
    # WAITING = 0, RUNNING = 1, ...
    instance_eval do
      self.const_set s.upcase.to_sym, i
    end
    # named_scope :status_waiting, :conditions => { :status => WAITING }
    named_scope "status_#{s}".to_sym, :conditions => { :status => i }
  end

  #Returns the string that represents the status
  def s_status
    case self.status
      when 0
        _("Waiting ...")
      when 1
        _("Running ...")
      when 2
        _("Ok")
      when 3
        _("Error")
      when 4
        _("Comented")
      when 5
        _("Not Run")
      when 6
        _("Stopped")
      else
        _("Complete")
    end
  end

  #Returns the string that represents the kind
  def s_kind
    case self.kind
      when 0
        _("History")
      when 1
        _("Alarm")
      when 2
        _("Task Program")
      else
        "Invalid"
    end
  end

  #Returns the string that represents the param kind 
  def self.s_kind(kind)
    case kind.to_i
      when 0
        _("History")
      when 1
        _("Alarms")
      when 2
        _("Task Programs")
      else
        "Invalid"
    end
  end

    
  def self.cancel(id)
   suite_execution=SuiteExecution.find id
    suite_execution.executions.each do |exe|
      if (exe.status== 0 or exe.status==1)
         exe.status=6
         exe.output = _("Canceled run")
         exe.save
         Rails.cache.delete "exec_#{exe.id}"
      end
    end
    Rails.cache.delete("suite_exec_#{id}") #Remove cache
     se = suite_execution.calculate_status #Recalculate status
     se.save
  end

  #Returns the status of suite_execution (depending of executions)
  def calculate_status
     #Get only the last execution of the scripts with one case
     last_executions_ids = Rails.cache.read("suite_exec_#{self.id}_last_executions")    
     last_executions_ids = self.executions.maximum(:created_at, :group => "circuit_id,case_template_id", :select=>:id).values  if !last_executions_ids

     #Get executions
     last_executions   = self.executions_cache(last_executions_ids)
     executions_status = last_executions.map(&:status)
     total = executions_status.length 
     #stoped
     if ( executions_status.include?(6) )#(al least one was cancel)
       self.status = 6  
       
     #Success
     elsif (executions_status.select {|v| [2,4].include?v }.length ==  total)#(all Success or comment)
       self.status = 2   
       
     #Running
     elsif ( executions_status.include?(1) or  ( (executions_status.include?(0)  and (executions_status.select {|v| [1,5].include?v}.length ==  0)) )  )#(at least one is running or (waiting and finish))
       self.status = 1
       
     #Waiting   
     elsif(executions_status.select {|v| v == 0 or v ==  4}.length ==  total)#(all waiting or comment)
       self.status = 0
       
     #Error
     elsif executions_status.include?(3)  or  executions_status.include?(5) #(at least one with error or not run)
       self.status = 3
       
     #Comment
     elsif (executions_status.select {|v| v ==  4}.length ==  total)#(all comment)
       self.status = 2   
       
     #Not run
     elsif (executions_status.select {|v| v == 5}.length ==  total)#(all not run)
       self.status = 5  
      
     #Complete
     else
       self.status = 8
     end 
   
   self
 end

  # Returns the last Execution of each script/case scenario
  def last_executions_status
    sorted_executions = self.executions.sort {|ex1, ex2| ex2.created_at <=> ex1.created_at }
    filtered_executions = []
    sorted_executions.each do |ex|
      filtered_executions << ex unless filtered_executions.find { |obj| obj.same_scenario? ex }
    end
    filtered_executions
  end

  def status_percentage
    executions = last_executions_status.reject {|ex| ex.status == COMMENTED }
    return 1 if executions.count == 0
    ok = executions.count {|s| s.status == OK }
    100 * ok / executions.count
  end

  # return executions from previous day which status is "running" but are already finished
  def self.last_idle_executions
    SuiteExecution.status_running.find :all, :conditions => ["created_at > ?", Date.yesterday.to_s]
  end

  # update old idle executions from RUNNING or WAITING to NOT_RUN
  def self.update_all_idle_executions
    SuiteExecution.update_all "status = #{NOT_RUN}", ["status = #{RUNNING} OR status = #{WAITING} AND created_at < ?", Date.yesterday.to_s]
  end

  def count_failures
    self.executions.count(:all, :conditions => "status = 3")
  end 

  def finished?
     #Not Waiting or Running
     ![0,1].include?(self.status) 
  end

  def executions_cache(execution_ids=nil)
    CaseTemplate
    DataRecovery
    Category
    DataRecoveryName
    Circuit
  
    #search execution in cache

    executions = []
  
    #if I have execution_ids, search them in cache
    #if not, search in DB

    if execution_ids
      execution_ids.each do |execution_id|
        execution = Rails.cache.fetch("exec_#{execution_id}"){ Execution.find execution_id }
        executions << execution
      end
    else
      executions = self.executions
    end
    
    executions
  
  end
  
  def execution_ids_cache
    #search suite_execution in cache
    all_suite_execution = Rails.cache.read "suite_exec#{self.id}"
    #if is cached, return executions ids
    if all_suite_execution
      return all_suite_execution[1]
    else
      #if not, search in DB

      return self.execution_ids
    end
  end
  
  
  def ordenar_executions(executions)
  
    order_executions = Array.new
    if self.suite_id != 0
      order = Schematic.find(   :all,
                                :conditions => ["suite_id = ? AND circuit_id IS NOT NULL", self.suite_id],
                                :order => "position ASC")
                              
      for ord in order
        order_executions += executions.select do |e|
          e.circuit.name == ord.circuit.name
        end
      end
    else
      order_executions = executions
    end
                            
    return order_executions
  
  end
  
  #load suite_execution with execution_ids cached
  def load_cache
    a = []
    a << self
    a << self.execution_ids
    #save execution suites in cache
    Rails.cache.write("suite_exec_#{self.id}",a,:expires_in => CACHE_EXPIRE_SUITE_EXEC)
    
    #Guardo en la cache cada una de las ejecuciones
    self.executions.each do |execution|
      Rails.cache.write("exec_#{execution.id}",execution,:expires_in => CACHE_EXPIRE_SUITE_EXEC)
      if execution.case_template_id == 0
        #Significa que es una corrida del tipo "self"
        Rails.cache.write("user_#{current_user.id}_circuit_#{execution.circuit_id}_self",execution.id,:expires_in => CACHE_EXPIRE_SUITE_EXEC)
      else
        #Actualizo la ultima ejecucion de cada caso para el usuario logueado
        Rails.cache.write("user_#{current_user.id}_ct_#{execution.case_template_id}",execution.id,:expires_in => CACHE_EXPIRE_SUITE_EXEC)
      end
    end 
  end
 
  
  #Load last executions of suite_execution
  def load_last_executions_cache
    #Get only the last execution of the scripts with case
    last_executions = self.executions.maximum(:created_at, :group => "circuit_id,case_template_id", :select=>:id) #Fotmato: circuit_id=>execution_id}
    executions_ids =  last_executions.values     
    #save execution suite in cache
    Rails.cache.write("suite_exec_#{self.id}_last_executions",executions_ids,:expires_in => CACHE_EXPIRE_SUITE_EXEC)
  end
  
  
  #suite_execution configurations to run
  #combination format = {:site => "br"}
  def create_configuration_to_run(configurations)
    configurations.each do |conf_name, conf_value|
      execution_configuration_value = self.execution_configuration_values.new
      context = ContextConfiguration.find_by_name(conf_name.to_s)
      execution_configuration_value.context_configuration_id = context.id if context
      execution_configuration_value.value = conf_value
      execution_configuration_value.save 
    end
  end
  
  #executions that the suite will have associated
  def calculate_executions(options)
    #add execution for case_template
    case_templates = []
    if options[:suite_id] == "0"
      if options.include?(:execution_run)
        options[:execution_run].each do |case_template_id|
            case_templates << CaseTemplate.find(case_template_id)
        end
        self.add_executions(case_templates)
      elsif options.include?(:case_template_id)
        if options[:case_template_id].empty?
            #run circuit_edit with "self"
            self.add_executions(["self"],options[:circuit_id])
        else
            #Run a unit case
            self.add_executions([CaseTemplate.find(options[:case_template_id])])
        end
      else
            raise _("ERROR: Must select any case to run")
      end
    else
      circuit_ids = options[:suite].circuit_ids
      comment_case_templates = []
      #suite run
      if options[:case_comment]
        case_comment_ids = options[:case_comment].split(";")
          options[:suite].case_templates.each do |case_template|
            if case_comment_ids.include?(case_template.id.to_s)
              comment_case_templates << case_template
            else
              case_templates << case_template
            end
            circuit_ids.delete(case_template.circuit_id)
          end
      else
          case_templates = options[:suite].case_templates
          case_templates.each{ |ct| circuit_ids.delete(ct.circuit_id) }
      end
        
      #The circuits which are not related cases in the suite are added in "self" mode
      circuit_ids.each{ |circuit_id| self.add_executions(["self"],circuit_id) }
      #add commentes cases
      self.add_executions(comment_case_templates,nil,4) if !comment_case_templates.empty?
      self.add_executions(case_templates)
    end    
  end


  #executions generator
  def add_executions(case_templates, circuit_id_to_self=nil, status=nil)

    if case_templates.include?("self")
      execution = self.executions.new
      execution.circuit_id = circuit_id_to_self
      execution.user_id = self.user_id
      execution.case_template_id = 0
      execution.save
    elsif status
      #generates all sended executions status 
      case_templates.each do |case_template|
        execution = self.executions.new
        execution.circuit_id = case_template.circuit_id
        execution.user_id = self.user_id
        execution.case_template_id = case_template.id
        execution.status = status
        execution.save
      end
    else
      case_templates.each do |case_template|
        execution = self.executions.new
        execution.circuit_id = case_template.circuit_id
        execution.user_id = self.user_id
        execution.case_template_id = case_template.id
        execution.save
      end
    end
  end
  
  #hash builder with ExecutionConfigurationValues
  def hash_execution_configuration_values
    hash = {}
    self.execution_configuration_values.each do |execution_configuration_value|

      hash[execution_configuration_value.context_configuration.name] = execution_configuration_value.value
    end
    
    hash
  end
  
  #It will show the command that you should use to run that configuration
  def self.generate_command(execution_params, function="run", user=nil)

    command = "cacique #{function} " 

    #Suite_id
    execution_params[:suite_ids] = execution_params[:suite_id] if execution_params[:suite_id]
    command += execution_params[:suite_ids].to_a.join(',') 
    if !current_user and !user
       userkey=User.find(execution_params[:user_id].to_i).api_key
    elsif user
       userkey=user.api_key
    else
       userkey=current_user.api_key
    end
    command += " -apikey #{userkey}"

    #Kind
    case function
      when "cron"
          command += " -kind 1"         
      when "program"
          command += " -kind 2" 
    end
   
    #commented cases
    if execution_params.has_key?(:case_comment)
      cases_comment = execution_params[:case_comment].split(";") 
      cases_comment.each do |case_com|
        command += " -c " + case_com.to_s
      end
    end
    
    #generating the conf params
    ContextConfiguration.all_enable.each do |context_configuration|
      if execution_params.has_key?(context_configuration.name.to_sym)  
       if context_configuration.view_type == "input" and execution_params[context_configuration.name.to_sym].strip.empty?
         #Por el momento no lo agrego al comando
       else
         if execution_params[context_configuration.name.to_sym].class == Array
           execution_params[context_configuration.name.to_sym].each do |value|
             #It will change  " " by _, otherwise the line command will fail
             value.gsub!(" ","_")
             command += " -#{context_configuration.name} " + value
           end
         else
           execution_params[context_configuration.name.to_sym].gsub!(" ","_")
           command += " -#{context_configuration.name} " + execution_params[context_configuration.name.to_sym]
         end
       end
      end
    end
    
    #Identifier
    if execution_params[:identifier] != " " and !execution_params[:identifier].empty?
      execution_params[:identifier].gsub!(" ","_")
      command += " -i " + execution_params[:identifier]
    end
    
    #Amount of times that will run
    if !execution_params[:cant_corridas].nil?
      if (execution_params[:cant_corridas] != "1") and !execution_params[:cant_corridas].empty?
        command += " -n " + execution_params[:cant_corridas]
      end
    end
    
    #run it on a ip
    if execution_params[:remote_control_mode] != "hub"
      command += " -ip " + execution_params[:remote_control_addr]
      command += " -port " + execution_params[:remote_control_port]
    end
     
    #SendEmail ok
    if execution_params.has_key?(:send_mail_ok) and execution_params.has_key?(:emails_to_send_ok)
        execution_params[:emails_to_send_ok].gsub!(",",";")
        emails = execution_params[:emails_to_send_ok].split(";")
        emails.each do |email|
          command += " -smo " + email
        end
    end
 
    #SendEmail fail
    if execution_params.has_key?(:send_mail_fail) and execution_params.has_key?(:emails_to_send_fail)
        execution_params[:emails_to_send_fail].gsub!(",",";")
        emails = execution_params[:emails_to_send_fail].split(";")
        emails.each do |email|
          command += " -smf " + email
        end
    end
   
    #DebugMode
    if execution_params.has_key?(:debug_mode)
      command += " -debug_mode true"
    end
    
    #server's ip
    command += " -server_ip " + SERVER_DOMAIN
    
    #server's port
    command += " -server_port " + execution_params[:server_port].to_s if execution_params.include?(:server_port)
    
    #log format
    command += " -format xml "

    command
    
  end
  
  def self.change_status_with_message(suite_execution_id, message, status, time_spent=0)
    suite_execution = SuiteExecution.find suite_execution_id
    #It was the "each" with ids because if was done with the "executions" throws error "can not modify frozen hash"
    suite_execution.executions.each do |execution|
      execution.status = status
      execution.output = message
      execution.time_spent = time_spent
      execution.save
    end
    suite_execution.status = 5
    suite_execution.save
    
    #caching suite_execution
    suite_execution.load_cache          
    #caching last executions of suite_execution
    suite_execution.load_last_executions_cache    
      
  end
  
  def self.generate_suite_execution_with_message(message, suite_id, identifier, user_id, context_configurations)
    suite = Suite.find(suite_id)
    suite_execution = SuiteExecution.create(:suite_id=>suite_id,:project_id=>suite.project_id, :identifier=>identifier,:user_id=>user_id, :status => 5, :time_spent => 0)

    suite_execution.create_configuration_to_run(context_configurations)
    
    suite.case_templates.each do |case_template|
      execution = suite_execution.executions.new
      execution.circuit_id = case_template.circuit_id
      execution.user_id = user_id
      execution.case_template_id = case_template.id
      execution.status = 5
      execution.time_spent = 0
      execution.save 
    end
    
    suite.circuits.each do |circuit|
      if circuit.case_templates.empty?
        execution = suite_execution.executions.new
        execution.circuit_id = circuit.id
        execution.user_id = user_id
        execution.case_template_id = 0
        execution.status = 5
        execution.time_spent = 0
        execution.output = message
        execution.save 
      end
    end
      
    suite_execution
  end  

  def self.filter(project,params)

    date        = params[:init_date]
    init_date   = Time.local(date.year, date.month, date.day, date.hour, date.min, date.sec).getutc
    date        = params[:finish_date]
    finish_date = Time.local(date.year, date.month, date.day, date.hour, date.min, date.sec).getutc

    user_id     = params[:filter] && params[:filter][:user_id]   && !params[:filter][:user_id].blank?  ? params[:filter][:user_id].to_i    : nil 
    suite_id    = params[:filter] && params[:filter][:suite_id]  && !params[:filter][:suite_id].blank? ? params[:filter][:suite_id].to_i   : nil
    script_id   = params[:filter] && params[:filter][:script_id] && !params[:filter][:script_id].blank? ? params[:filter][:script_id].to_i : nil   
    status      = params[:filter] && params[:filter][:status]    && !params[:filter][:status] && params[:filter][:status].to_i != -1 ? params[:filter][:status].to_i : nil
    identifier  = params[:filter] && params[:filter][:identifier] && !params[:filter][:identifier].blank? ? params[:filter][:identifier] : nil
    kind        = params[:kind] ? params[:kind] : 0



    #Bulid conditions
    conditions        = Array.new
    conditions_values = Array.new
    conditions_names  = Array.new
    query_include     = Array.new

    #Project   
    conditions_names  <<  " suite_executions.project_id = ? "
    conditions_values <<  project.id

    #Identifier  
    if identifier
      conditions_names  <<  " suite_executions.identifier like ? "
      conditions_values << '%' + identifier + '%'
    end

    #user
    if user_id
      conditions_names  <<  " suite_executions.user_id = ? "
      conditions_values <<  user_id
    end

    #Kind
    conditions_names  <<  " suite_executions.kind = ? "
    conditions_values <<  kind  

    #suite
    if suite_id
      conditions_names  <<  " suite_executions.suite_id = ? "
      conditions_values <<  suite_id   
    end

    #status
    if status
      conditions_names  <<  " suite_executions.status = ? "
      conditions_values <<  status.to_i
    end       

    #Dates
    conditions_names << " suite_executions.created_at BETWEEN ? AND ? " 
    conditions_values << init_date   
    conditions_values << finish_date

    #Script
    if script_id
      conditions_names  <<  " executions.circuit_id = ? "
      conditions_values <<  script_id  
      query_include     << :executions
    end

    #Context configurations
     if params[:context_configurations]
      query_include << :execution_configuration_values
      #Get boolean context configuration
      boolean_context_configuration = (ContextConfiguration.find_all_by_view_type "boolean").map(&:id)
      params[:context_configurations].each do | context_configuration_id , context_configuration_values |
        if (!context_configuration_values.empty? or boolean_context_configuration.include?(context_configuration_id.to_i))
          #Boolean
          if boolean_context_configuration.include?(context_configuration_id.to_i) and context_configuration_values.empty?
            values_sql_statment =  "('')"
          else
            values_sql_statment =  "(" + context_configuration_values.collect{|ccv| "\'" + ccv + "\'"}.to_a.join(',') + ")"
          end
          conditions_names  << " EXISTS (SELECT * FROM execution_configuration_values WHERE suite_executions.id = execution_configuration_values.suite_execution_id AND execution_configuration_values.context_configuration_id = #{context_configuration_id.to_i} AND execution_configuration_values.value in #{values_sql_statment})  " 
        end
      end
    end

    #Build conditions
    conditions << conditions_names.join("and")  
    conditions = conditions + conditions_values 

    suite_executions = SuiteExecution.find :all, :conditions=>conditions, :order => 'suite_executions.created_at DESC', :include => query_include
 
    #Paginate
    number_per_page=9
    number_per_page= params[:filter][:paginate].to_i if params[:filter] && params[:filter].include?(:paginate) 
    suite_executions.paginate :page => params[:page], :per_page => number_per_page

  end
  
  #Get percentages of states
  def self.get_rates(suite_executions)
     total  = suite_executions.count
     total = 1 if total == 0
     ok     = suite_executions.count{|se| se.status == 2} 
     error  = suite_executions.count{|se| se.status == 3} 
     others = total -  ok - error
     rates = {:ok=>[ok,(ok*100/total.to_f).round(2)], :error=>[error,(error*100/total.to_f).round(2)], :others=>[others,(others*100/total.to_f).round(2)] }
  end

  def stop
    self.executions.each{|exe| exe.stop if (!exe.finished?)  }
    self.calculate_status
  end



end
