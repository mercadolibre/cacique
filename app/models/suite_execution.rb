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
  def self.generate_command(execution_params, function=nil)
    if function
      command = "cacique #{function} " 
    else
      command = "cacique run "
    end
 
    #Suite_id
    execution_params[:suite_ids] = execution_params[:suite_id] if execution_params[:suite_id]
    command += execution_params[:suite_ids].to_a.join(',') 
    current_user= User.find(execution_params[:user_id].to_i if !current_user
    command += " -apikey #{current_user.api_key}"
   
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
    
    #Program
    if execution_params.has_key?(:task_program_id)
      command += " -task_program_id " + execution_params[:task_program_id].to_s
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
   init_date    = params[:init_date] ? DateTime.strptime(params[:init_date], "%d.%m.%Y %H:%M"): DateTime.strptime( (DateTime.now.in_time_zone - (7*24*60*60)).to_s , "%Y-%m-%d %H:%M")#7 days after
  finish_date  = params[:init_date] ? DateTime.strptime(params[:finish_date], "%d.%m.%Y %H:%M") : DateTime.strptime(  DateTime.now.in_time_zone.to_s , "%Y-%m-%d %H:%M:%S")

   #Bulid include
    query_include     = Array.new

   #Bulid conditions
    conditions        = Array.new
    conditions_values = Array.new
    conditions_names  = Array.new
   
    #Project   
    conditions_names  <<  " suite_executions.project_id = ? "
    conditions_values <<  project.id
    #Dates
    conditions_names  <<  " suite_executions.created_at <= ? "
    date = finish_date
    conditions_values <<  Time.local(date.year, date.month, date.day, date.hour, date.min, date.sec).getutc
    conditions_names  <<  " suite_executions.created_at >= ? "
    date = init_date
    conditions_values <<  Time.local(date.year, date.month, date.day, date.hour, date.min, '00').getutc  
    #Identifier  
    identifier  = params[:identifier]
    if identifier && !identifier.empty?
      conditions_names  <<  " suite_executions.identifier like ? "
      conditions_values << '%' + identifier + '%'
    end
    #user
    user = params[:user_id]
    if user && !user.empty? 
      conditions_names  <<  " suite_executions.user_id = ? "
      conditions_values <<  user   
    end
    #status
    status = params[:status]
    if status && status.to_i != -1
      conditions_names  <<  " suite_executions.status = ? "
      conditions_values <<  status.to_i
    end        

   case params[:model] 
    #SUITES
    when "suites"
            #Programs
            if params[:programs] == "1"
               #Conditions for task programs 
               tp_conditions        = Array.new
               tp_conditions_values = Array.new
               tp_conditions_names  = Array.new 
               if user && !user.empty? 
                  tp_conditions_names  <<  " user_id = ? "
                  tp_conditions_values <<  user   
               end  
               if !params[:suite_id].empty?
                  tp_conditions_names  << " suite_id  = ? " 
                  tp_conditions_values <<  params[:suite_id]
               end    
               tp_conditions << tp_conditions_names.join("and")  
               tp_conditions = tp_conditions + tp_conditions_values                         
               task_program_suite_executions = TaskProgram.find :all, :conditions=>tp_conditions 
               #For all task programs get the suite_executions_ids
               suite_execution_ids = Array.new
               task_program_suite_executions.each do |tp|
                 #Add array with suite_execution_ids
                 suite_execution_ids = suite_execution_ids + tp.suite_execution_ids.split(",") if tp.suite_execution_ids && !tp.suite_execution_ids.empty?
               end                 
               if !suite_execution_ids.empty?
                  conditions_names  << " suite_executions.id  in (?)" 
                  conditions_values <<  suite_execution_ids.collect{|x| x.to_i}#Ids string to integer
               else
                  conditions_names  << " suite_executions.suite_id  <> ? " 
                  conditions_values <<  0     
               end        
            #all (Programs or not)
            else
               #Search specific suite
               if !params[:suite_id].empty?
                  conditions_names  << " suite_executions.suite_id  = ? " 
                  conditions_values <<  params[:suite_id]
               else
                  conditions_names  << " suite_executions.suite_id  <> ? " 
                  conditions_values <<  0            
               end
            end    
      #SCRIPTS
      when  "scripts"
            query_include << "executions"
            conditions_names  << " suite_executions.suite_id  = ? " 
            conditions_values << 0    
            #Search specific script
            if !params[:circuit_id].nil?  && !params[:circuit_id].empty? 
            conditions_names  << " executions.circuit_id  = ? " 
            conditions_values << params[:circuit_id] 
               #Search specific case
               if !params[:case_id].nil?  && !params[:case_id].empty? 
                  conditions_names  << " executions.case_template_id  = ? " 
                  conditions_values << params[:case_id]
               end
             end 
      end

     #Context configurations
     if params[:context_configurations]
        query_include << "execution_configuration_values"
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
    return suite_executions
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
