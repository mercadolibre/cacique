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
# == Schema Information
# Schema version: 20101129203650
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
        _("Success")
      when 3
        _("Error")
      when 4
        _("Comented")
      when 5
        _("Not Run")
      else
        _("Complete")
    end
  end
  
  #Returns the status of suite_execution (depending of executions)
  def calculate_status

     #Get only the last execution of the scripts
     last_executions_ids = Rails.cache.read("suite_exec_#{self.id}_last_executions")
     last_executions_ids = self.executions.maximum(:created_at, :group => :circuit_id, :select=>:id).values  if !last_executions_ids
 
     #Get executions
     last_executions   = self.executions_cache(last_executions_ids)
     executions_status = last_executions.map(&:status)
     total = executions_status.length 

     #Success
     if (executions_status.select {|v| [2,4].include?v }.length ==  total)#(all Success or comment)
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
      
     #Not defined
     else
       self.status = 6
   end 
   
   self
 end

  def count_failures
    self.executions.count(:all, :conditions => "status = 3")
  end 

  
  def finished?
    self.executions.count == self.executions.count(:conditions => "status = 2 or status = 3 or status = 4 or status = 5")
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
    #Get only the last execution of the scripts
    last_executions = self.executions.maximum(:created_at, :group => :circuit_id, :select=>:id) #Fotmato: circuit_id=>execution_id}
    executions_ids =  last_executions.values     
    #save execution suite in cache
    Rails.cache.write("suite_exec_#{self.id}_last_executions",executions_ids,:expires_in => CACHE_EXPIRE_SUITE_EXEC)
  end
  
  
  #suite_execution configurations to run
  #combination format = {:site => "br"}
  def create_configuration_to_run(configurations)
    configurations.each do |conf_name, conf_value|

      execution_configuration_value = self.execution_configuration_values.new
      context = ContextConfiguration.find_by_name(conf_name)
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
      execution.user_id = current_user.id
      execution.case_template_id = 0
      execution.save
    elsif status
      #Genero todas las executions con el status recibido
      case_templates.each do |case_template|
        execution = self.executions.new
        execution.circuit_id = case_template.circuit_id
        execution.user_id = current_user.id
        execution.case_template_id = case_template.id
        execution.status = status
        execution.save
      end
    else
      case_templates.each do |case_template|
        execution = self.executions.new
        execution.circuit_id = case_template.circuit_id
        execution.user_id = current_user.id
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
  
  #Genera el comando que se debe utilizar para poder correr una suite remotamente
  def self.generate_command(execution_params, function=nil)
    if function
      command = "cacique #{function} "
    else
      command = "cacique run "
    end
  
    #Suite_id
    command += execution_params[:suite_id]
    
    #UserName
    command += " -u \<user_name\>"
    #UserPass
    command += " -p \<user_pass\>"
  
    #Casos comentados
    if execution_params.has_key?(:case_comment)
      cases_comment = execution_params[:case_comment].split(";") 
      cases_comment.each do |case_com|
        command += " -c " + case_com.to_s
      end
    end
    
    #Genero los comandos para las configuraciones parametrizables
    ContextConfiguration.all_enable.each do |context_configuration|
      if execution_params.has_key?(context_configuration.name.to_sym)  
       if context_configuration.view_type == "input" and execution_params[context_configuration.name.to_sym].strip.empty?
         #Por el momento no lo agrego al comando
       else
         if execution_params[context_configuration.name.to_sym].class == Array
           execution_params[context_configuration.name.to_sym].each do |value|
             #Por las dudas reemplazo los " " por _
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
    
    #Identificador
    if execution_params[:identifier] != " " and !execution_params[:identifier].empty?
      execution_params[:identifier].gsub!(" ","_")
      command += " -i " + execution_params[:identifier]
    end
    
    #Cant de corridas
    if (execution_params[:cant_corridas] != "1") and !execution_params[:cant_corridas].empty?
      command += " -n " + execution_params[:cant_corridas]
    end
    
    #Corrida BenderEnMiPC
    if execution_params[:remote_control_mode] != "hub"
      command += " -ip " + execution_params[:remote_control_addr]
      command += " -port " + execution_params[:remote_control_port]
    end
    
    #SendEmail
    if execution_params.has_key?(:send_mail) and execution_params.has_key?(:emails_to_send)
        execution_params[:emails_to_send].gsub!(",",";")
        emails = execution_params[:emails_to_send].split(";")
        emails.each do |email|
          command += " -sm " + email
        end
    end
    
    #Ip del Servidor
    command += " -server_ip " + IP_SERVER
    
    #Port del Servidor
    command += " -server_port " + execution_params[:server_port].to_s if execution_params.include?(:server_port)
    
    #Formato del logueo devuelto
    command += " -format xml "
    
    
    command
    
  end
  
end


