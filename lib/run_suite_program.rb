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
#Schedule Suite Class
class RunSuiteProgram < Struct.new(:params)

  def perform
    dj = DelayedJob.find(params[:delayed_job_id])
  
    #Manejo de Estados
    case dj.status
      when 0
        #Ignoro la ejecucion, porque todavia no tengo re-confirmacion
        context_configurations = {}
        ContextConfiguration.all_enable.each do |context_configuration|
          context_configurations[context_configuration.name.to_sym] = params[context_configuration.name.to_sym].to_s
        end
        suite_execution = SuiteExecution.generate_suite_execution_with_message("Not executed because the programming was pending to confirm", params[:suite_id], params[:identifier], params[:user_id], context_configurations)

      when 1
        #Ejecuto Normalmente
        run_program( params )
      
      when 2
        if dj.task_program.delayed_jobs.count != 1 
          #Envio pedido de re-confirmacion para las proximas corridas
          Notifier.deliver_confirm_program(params[:user_mail] ,params[:task_program_id], params[:server_port], params[:suite_id])
        end
        #Ejecuto Normalmente
        run_program( params )
      
      else
        #Estado no valido    
        context_configurations = {}
        ContextConfiguration.all_enable.each do |context_configuration|
          context_configurations[context_configuration.name.to_sym] = params[context_configuration.name.to_sym].to_s
        end
        suite_execution = SuiteExecution.generate_suite_execution_with_message("Not executed because the programming has an unknown state: #{dj.status}", params[:suite_id], params[:identifier], params[:user_id], context_configurations)
    end
    #Delete Task program withuot delayed jobs
    task_program = TaskProgram.find(params[:task_program_id])
    task_program.destroy if task_program.delayed_jobs.count == 0

  rescue
    puts $!
    puts $@
  end
  
  def run_program( args )

    command = SuiteExecution.generate_command(args, "program") 

    #Complete User & pass
    #UserName
    command.gsub!("\<user_name\>",FIRST_USER_NAME)
    #UserPass
    command.gsub!("\<user_pass\>",FIRST_USER_PASS)

    system("#{RAILS_ROOT}/lib/#{command}")

  rescue
    puts $!
    puts $@
  end
  
end
