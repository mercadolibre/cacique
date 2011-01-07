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


class ExecutionsController < ApplicationController
  protect_from_forgery :except => [:new]
  skip_before_filter :verify_authenticity_token

  skip_before_filter :context_stuff, :only => :update_execution

  def show_snapshot
    sp = ExecutionSnapshot.find params[:snapshot_id]

    @html_code = sp.content

    render :html => "<html></html>"
  end


  def save_execution_config

    @user_configuration = UserConfiguration.find_by_user_id(current_user.id)
    
    @user_configuration.send_mail = params[:execution].has_key?(:send_mail)
    @user_configuration.debug_mode = params[:execution].has_key?(:debug_mode)
    @user_configuration.remote_control_addr = params[:execution][:remote_control_addr]
    @user_configuration.remote_control_port = params[:execution][:remote_control_port]
    @user_configuration.remote_control_mode = params[:execution][:remote_control_mode]
   
    @user_configuration.change_user_configuration_values(params[:execution])

    if @user_configuration.save

    else
      render :text => _("Setting was not saved")
    end
   render :nothing => true
 end

 # Runs an execution again
  def retry_run
   Execution
   SuiteExecution
   ExecutionConfigurationValue
   Circuit
      @execution = Rails.cache.fetch("exec_#{params[:id]}",:expires_in => CACHE_EXPIRE_EXEC){ Execution.find(params[:id]) }

      @user_configuration = UserConfiguration.find_by_user_id(current_user.id)

      @new_execution = Execution.create(
                          :circuit_id         => @execution.circuit_id,
                          :user_id            => @execution.user_id,
                          :case_template_id   => @execution.case_template_id,
                          :suite_execution_id => @execution.suite_execution_id
                        )
      
      #update cached suite_execution
      suite_execution_cache = Rails.cache.read "suite_exec_#{@execution.suite_execution_id}"

      suite_execution_db = SuiteExecution.find @execution.suite_execution_id
      if suite_execution_cache
        #is caching else update with new execution
        suite_execution_cache[0] = suite_execution_db
        suite_execution_cache[1] << @new_execution.id
        Rails.cache.write("suite_exec_#{@execution.suite_execution_id}",suite_execution_cache,:expires_in => CACHE_EXPIRE_SUITE_EXEC)
      else
        #Caching suite_execution
        suite_execution_db.load_cache
      end
 
      args = Hash.new
      @user_configuration.attributes.each do |k,v|
        args[k.to_sym] = v
      end
      
      args[:execution_id] = @new_execution.id
      args[:execution_tag] = "exec_#{@new_execution.id}"
      args[:configuration_values] = suite_execution_db.hash_execution_configuration_values
      args[:project_id] = params[:project_id]


      ExecutionWorker.asynch_retry_execution(args)

      redirect_to "/suite_executions/" + suite_execution_db.id.to_s

  end

end
