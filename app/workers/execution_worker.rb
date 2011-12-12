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
  def retry_block(max_retries, puts_message, error_text)
    retries = 0
    begin
      yield
    rescue Exception => e
      retries += 1
      if retries > max_retries
        puts "#{puts_message} #{retries} #{e}"
        raise "#{error_text} #{e}"
      end 
      sleep rand(5)
      retry
    end
  end

  def retry_save(max_retries=3)
    retry_block(max_retries, "Retrying worker: ", "error, after retry") do
      yield
    end
  end

require "#{RAILS_ROOT}/lib/suites/suite_cases_runner.rb"
require "#{RAILS_ROOT}/lib/suites/suite_cases_runner_db.rb"
require "#{RAILS_ROOT}/lib/suites/suite_relation.rb"
require "#{RAILS_ROOT}/lib/suites/fake_oracle.rb"
#Requires to prevent cahcing errors
require_dependency "#{RAILS_ROOT}/app/models/circuit.rb"
require_dependency "#{RAILS_ROOT}/app/models/case_template.rb"
require_dependency "#{RAILS_ROOT}/app/models/execution.rb"
require_dependency "#{RAILS_ROOT}/app/models/suite_execution.rb"
require_dependency "#{RAILS_ROOT}/app/models/suite_container.rb"
require_dependency "#{RAILS_ROOT}/app/models/execution_configuration_value.rb"

class ExecutionWorker < Workling::Base

  def run_suite(options)

    #search suite execution in cache
    all_suite_execution = Rails.cache.fetch(options[:suite_execution_tag],:expires_in => CACHE_EXPIRE_SUITE_EXEC){ s = SuiteExecution.find options[:suite_execution_id];[s,s.execution_ids] }
    suite_execution = all_suite_execution[0]

    #search execution in cache
    suite_execution_executions = Array.new
    all_suite_execution[1].each do |execution_id|
      suite_execution_executions << Rails.cache.fetch("exec_#{execution_id}",:expires_in => CACHE_EXPIRE_SUITE_EXEC){ Execution.find execution_id }
    end

    #Add the suite_id in the hash of options
    options[:suite_id] = suite_execution.suite_id

    if suite_execution.suite_id != 0
      #I'm running a suite
      executions = []
      suite_execution.executions.each do |execution|
        executions << execution if execution.status != 4
      end
      options[:executions] = suite_execution.ordenar_executions(executions)
    else
      #Unit Run
      options[:executions] = suite_execution.executions    
    end
    options[:suite_cases_runner] = @suite_cases_runner = SuiteCasesRunner.new

    #Update suite execution
    #Always "Running", but if you have all the cases commented should be "Success"
    all_suite_execution[0].calculate_status 
    Rails.cache.write("suite_exec_#{suite_execution.id}",all_suite_execution,:expires_in => CACHE_EXPIRE_SUITE_EXEC)
    run_executions(options)
    Rails.cache.delete WORKER_CACHE_KEY

    #Update suite execution db
    all_suite_execution = Rails.cache.fetch(options[:suite_execution_tag],:expires_in => CACHE_EXPIRE_SUITE_EXEC){ s = SuiteExecution.find options[:suite_execution_id];[s,s.execution_ids] }
    db_suite_execution = all_suite_execution[0]
    db_suite_execution.calculate_status
    db_suite_execution.save

    #Send mail OK
    if (db_suite_execution.status == 2 and options[:send_mail_ok])
      begin
        if suite_execution.suite_id == 0
          Notifier.deliver_execution_single_alert(db_suite_execution,options[:emails_to_send_ok])
        else
          Notifier.deliver_suite_execution_alert(db_suite_execution,options[:emails_to_send_ok])
        end
      rescue
        print "Failure to send notification: "
        p $!
      end
    #Send mail FAIL
    elsif (db_suite_execution.status != 2 and options[:send_mail_fail])
      begin
        if suite_execution.suite_id == 0
          Notifier.deliver_execution_single_alert(db_suite_execution,options[:emails_to_send_fail])
        else
          Notifier.deliver_suite_execution_alert(db_suite_execution,options[:emails_to_send_fail])
        end
      rescue
        print "Failure to send notification: "
        p $!
      end
    end

    rescue Exception => e
      print "run_suite error: #{e.to_s}\n"
  end

  #Execute N times a suite
  def run_n_times(options)
    first = true
    options[:veces].times do
      if first
        suite_executions = options[:suite_executions]
        first = false
      else
        suite_executions = []
        options[:suite_executions].each do |s|
          new_suite_execution = SuiteExecution.create(s.attributes)
          s.execution_configuration_values.each do |exe|
            new_exe_conf_value = ExecutionConfigurationValue.create(exe.attributes.merge(:suite_execution_id=>new_suite_execution.id))
          end 
          s.executions.each do |e|
            new_execution = Execution.new
            new_execution.suite_execution_id = new_suite_execution.id
            new_execution.circuit_id = e.circuit_id
            new_execution.user_id = e.user_id
            new_execution.case_template_id = e.case_template_id
            new_execution.save
          end
          suite_executions << new_suite_execution
        end#options[:suite_executions].each
      end#if first

      suite_executions.each do |suite_execution|
        options[:suite_execution_id] = suite_execution.id
        options[:suite_execution_tag] = "suite_exec_#{suite_execution.id}"
        options[:configuration_values] = suite_execution.hash_execution_configuration_values
        run_suite(options)
      end
    end#options[:veces]
  end

  def run_executions(options)
    @suite_relation = SuiteRelation.new(options[:suite_cases_runner], options[:suite_id])
    #caching suite execution
    cache_suite_execution = Rails.cache.fetch("suite_exec_#{options[:suite_execution_id]}",:expires_in => CACHE_EXPIRE_SUITE_EXEC){ s = SuiteExecution.find options[:suite_execution_id]; [s,s.execution_ids] }            
    ccq_restart_worker = false
    options[:executions].each do |@execution|
      begin
        starting_time = Time.now
        script_runner = ScriptRunner.new
        @suite_relation.reset_output
        begin
          @execution.status = 1
          #caching status
          cache_execution = Rails.cache.fetch("exec_#{@execution.id}",:expires_in => CACHE_EXPIRE_SUITE_EXEC){ Execution.find @execution.id }
          cache_execution.status = 1
          #save execution status in cache
          Rails.cache.write("exec_#{@execution.id}",cache_execution,:expires_in => CACHE_EXPIRE_SUITE_EXEC)
          datos_recuperados = Hash.new
          ###################################################
          data = Hash.new
          if @execution.case_template_id != 0
            @suite_relation.find_relation(@execution.case_template_id, options[:suite_id] , @execution.suite_execution_id)
            data = @suite_relation.data
          end
          data[:execution_id] = @execution.id
          ####################################################
          if options[:remote_control_mode] == "hub"
            script_runner.remote_control_addr = HUB_IP
            script_runner.remote_control_port = HUB_PORT
          else
            script_runner.remote_control_addr = options[:remote_control_addr]
            script_runner.remote_control_port = options[:remote_control_port].to_i
          end

          script_runner.execution = @execution
          script_runner.data = data
          script_runner.data_recoveries = @execution.circuit.data_recoveries_hash
          script_runner.debug_mode = options[:debug_mode]
          script_runner.project_id = options[:project_id]
          script_runner.free_values=options[:free_values] 
          @execution.output = ""
          #Get the default configurations and set the value in the output
          aux_configuration_values = {}
          values_default = options[:configuration_values].select {|k,v| v == "default"} #Format: [["conf1", "value1"], ["conf2", "value2"], ..]
          @execution.output = "Valores Default del caso:\n" if !values_default.empty? 
          values_default.each do |value|
            if @execution.case_template_id == 0
              aux_configuration_values[value[0]] = ""
            else
              aux_configuration_values[value[0]] = @execution.case_template.get_case_data["default_" + value[0]]
            end
            @execution.output += value[0] + " : " + aux_configuration_values[value[0]] + "\n"
          end
          @execution.output += "\n" unless @execution.output.empty?
          script_runner.configuration_values = options[:configuration_values].merge(aux_configuration_values)
          execution = @execution
          script_runner.instance_eval{
            @circuit = execution.circuit
            @snapshot_execution_id = execution.id
          }
          ##########################################################################
          def script_runner.process_snapshot( name, content )
            sp = ExecutionSnapshot.new
            sp.content = content
            sp.name = name
            sp.execution_id = @snapshot_execution_id
            sp.save
          end
          #############################################################################        
          print "Running execution #{@execution.id} from suite: #{@execution.suite_execution_id}...  \n" if options[:debug_mode]
          datos_recuperados = script_runner.run_source_code( @execution.circuit.source_code )
          @execution.output +=  @suite_relation.output + script_runner.output
          cache_execution.output = @suite_relation.output + script_runner.output
          if @execution.case_template_id != 0
            @suite_relation.process_return_values(@execution.case_template_id, data, datos_recuperados)
          end

          if script_runner.execution_flag==1
            @execution.status=6
            Rails.cache.write("exec_#{@execution.id}",@execution,:expires_in => CACHE_EXPIRE_SUITE_EXEC)
            @execution.save
            cache_execution=Rails.cache.read("exec_#{@execution.id}")
            #Rails.cache.delete "suite_exec_#{suite_execution.id}"
        end
        #Error
        rescue Exception => e

          @execution.output ||= ""
          cache_execution.output ||= ""
          @execution.output +=  @suite_relation.output + script_runner.output
          cache_execution.output +=  @suite_relation.output + script_runner.output
          @suite_relation.executions_error << @execution.case_template_id

          #Parse text error
          error_text,position_error = parser_error(e)
          @execution.error          = error_text
          cache_execution.error     = error_text
          @execution.position_error       = position_error
          cache_execution.position_error  = position_error

          if e.instance_of? SuiteRelation::FatherRelationError or e.instance_of? SuiteCasesRunnerDb::FatherRelationError
            @execution.status = 5
            cache_execution.status = 5
            @execution.output += e.to_s
            cache_execution.output += e.to_s
          else
            @execution.status = 3
            cache_execution.status = 3
          end
        end#rescue Exception => e
        if datos_recuperados.instance_of? Hash
          if datos_recuperados.include?(:error)
            @execution.error = datos_recuperados[:error]
            @execution.status = 3
            cache_execution.error = datos_recuperados[:error]
            cache_execution.status = 3
            @suite_relation.executions_error << @execution.case_template_id
          else
            datos_recuperados.each do |k,v|
            data_recovery = @execution.data_recoveries.new
            data_recovery.execution_id = @execution.id
            data_recovery.data_name = k
            data_recovery.data = v
            retry_save do
              data_recovery.save
            end
          end
        end#if datos_recuperados.instance_of? Hash
      end# Begin

      if @execution.status != 3 and @execution.status != 5 and @execution.status != 6
        @execution.status = 2 
        cache_execution.status = 2
      end
      #Error   
      rescue  Exception => e

        @execution.status = 3 #Error
        @execution.error  = e
        cache_execution.status = 3
        cache_execution.error  = e

      ensure
        @execution.time_spent = Time.now - starting_time
        cache_suite_execution[0].time_spent += @execution.time_spent 
        #caching new execution status
        Rails.cache.write("exec_#{@execution.id}",@execution,:expires_in => CACHE_EXPIRE_SUITE_EXEC)
        #caching new suite execution status
        cache_suite_execution[0].calculate_status
        Rails.cache.write("suite_exec_#{cache_suite_execution[0].id}",cache_suite_execution,:expires_in => CACHE_EXPIRE_SUITE_EXEC)
        retry_save do
          @execution.save
        end
        ccq_restart_worker = true if  !ccq_restart_worker and (script_runner.ccq_exec_flag == 1) 
      end
    end#End executions
    system("kill -9 #{$$}") if ccq_restart_worker
  end
  
  def retry_execution( options )

    @execution = Rails.cache.fetch(options[:execution_tag],:expires_in => CACHE_EXPIRE_SUITE_EXEC){ Execution.find( options[:execution_id] ) }
    suite_execution = @execution.suite_execution
    options[:executions]         = [@execution]
    options[:suite_id]           = suite_execution.suite_id
    options[:suite_execution_id] = suite_execution.id
    @suite_cases_runner_db = SuiteCasesRunnerDb.new
    @suite_cases_runner_db.execution_id = @execution.id
    options[:suite_cases_runner] = @suite_cases_runner_db

    #Update suite execution cache
    cache_suite_execution = Rails.cache.fetch("suite_exec_#{suite_execution.id}",:expires_in => CACHE_EXPIRE_SUITE_EXEC){ s = SuiteExecution.find suite_execution.id; [s,s.execution_ids] }            
    cache_suite_execution[0].status = 1 #Runing
    Rails.cache.write("suite_exec_#{suite_execution.id}",cache_suite_execution,:expires_in => CACHE_EXPIRE_SUITE_EXEC)
    #Load last executions of suite_execution
    @execution.suite_execution.load_last_executions_cache
    
    #Update suite execution DB
    db_suite_execution        = SuiteExecution.find suite_execution.id
    db_suite_execution.status = 1
    db_suite_execution.save
    run_executions(options)
    Rails.cache.delete WORKER_CACHE_KEY 
    #Update suite execution db
    cache_suite_execution = Rails.cache.fetch("suite_exec_#{suite_execution.id}",:expires_in => CACHE_EXPIRE_SUITE_EXEC){ s = SuiteExecution.find suite_execution.id; [s,s.execution_ids] }            
    db_suite_execution = cache_suite_execution[0]
    db_suite_execution.calculate_status
    db_suite_execution.save
    
    rescue Exception => e
      print $@
      print "retry error: #{e.to_s}\n"
  end # def retry_suite
  
  ##########################################################
  ##############           OTHERS           ################

  def execution_success?(suite_execution_id)
    suite_execution = SuiteExecution.find(suite_execution_id)
    status = suite_execution.executions.map(&:status).uniq
    if status == 2
      true
    else
      false
    end
  end

  def find_data(case_id)
    case_data = CaseTemplate.find(case_id).get_case_data()
    case_data
  end

  def parser_error( error )
    #Detele Cacique paths
    error.to_s.gsub!(/(\/\w+)*.\w+:\d+:in `ccq_\w+':/, "")

    #Detele Cacique functions
    error.to_s.gsub!(/`ccq_\w+':/, "")

    errors = error.to_s.split("---> Error: <---")
    error_text     = errors[0]
    position_error = errors[1]
    [error_text, position_error]
  end

end

