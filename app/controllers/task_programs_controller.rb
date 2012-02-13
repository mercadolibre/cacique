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
class TaskProgramsController < ApplicationController

  def new
    @suite_id    = params[:id]  if params[:id]
    @init_date   = Time.now
    @finish_date = Time.now + (24*60*60) #Tomorrow

    #obtain user configuration
    @user_configuration = UserConfiguration.find_by_user_id(current_user.id)
    @user_configuration_values = @user_configuration.get_hash_values
    @column_1, @column_2 = ContextConfiguration.calculate_columns
    @suite_execution = SuiteExecution.new
    @command = params[:command]

    #Data for program
    @suites       = Suite.find :all, :conditions=>["project_id = ?", params[:project_id]], :order => "name"
    @weekly       = Date::DAYNAMES 
    @weekly_trans = {"Sunday"=>_("Sunday"),"Monday"=>_("Monday"),"Tuesday"=>_("Tuesday"),"Wednesday"=>_("Wednesday"),"Thursday"=>_("Thursday"),"Friday"=>_("Friday"),"Saturday"=>_("Saturday")}
    @range_repeat  = [ [_("Each"), "each"], [_("Specify"),"specific"] ]
    @each_hour_or_min  = [ [_("hs."), "hours"], [_("min"),"min"] ]
    @cell_selects = ContextConfiguration.build_select_data #Build the selects for edit cell

  end

  def confirm
    @text_confirm = ''    
    @text_error   = TaskProgram.validate_params(params)   
    if @text_error.empty? 
        params[:execution][:server_port] = request.port if request.port != 80
        cant_times  = TaskProgram.generate_times_to_run(params[:program]).count
        cant_suites = params[:execution][:suite_ids].include?("0")? Suite.find_all_by_project_id(params[:project_id]).count : params[:execution][:suite_ids].count
        @user_configuration = current_user.user_configuration
        @user_configuration.update_configuration(params[:execution])
        cant_run_combination = @user_configuration.run_combinations.count
        @suite_program_cant = cant_times * cant_suites * cant_run_combination
         @create_path = url_for(params.merge!(:action => :create))
         if @suite_program_cant > MAX_SUITE_PROGRAM
            @text_confirm = _("You are to be scheduled #{@suite_program_cant} executions, please enter the number of executions to confirm.") 
         end
     end

     respond_to do |format|
         format.html
         format.js # run the confirm.rjs template
     end
  end


  def create
    params[:execution][:server_port] = request.port if request.port != 80
    @user_configuration = current_user.user_configuration
    @user_configuration.update_configuration(params[:execution])
    TaskProgram.create_all(params)
    path = (params[:program][:range] == "alarm")? crons_path : delayed_jobs_path
    redirect_to path
  end

   #Removes a collection of Delayed Jobs
   def destroy
    if params[:id]
      task_program_ids = params[:id].map{|x| x.to_i}
      TaskProgram.destroy_all(task_program_ids)
      redirect_to :back, :filter=>params[:filter] #Crons or delayed jobs
    end
   end

  def show_suites_of_project
    if params[:filter][:project_id] == ''
      @suites = Suite.find :all
    else
      project = Project.find params[:filter][:project_id]
      @suites= project.suites
    end
    render :partial => "select_suites_of_project", :locals => { :suites=>@suites, :suite_id=>nil }
  end

end


