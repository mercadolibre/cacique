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

  def index
    Suite
    @projects     = Project.all
    @users        = User.all   
    @project_id   = params[:project_id] = (params[:filter] && params[:filter][:project_id])? params[:filter][:project_id].to_i : params[:project_id].to_i

    #Suites
    #One project selected
    if @project_id != 0 
      #Read suites ids from cache
      suites_ids = Rails.cache.read("project_suites_#{@project_id}")
      suites_ids = Project.find(@project_id).suite_ids if !suites_ids
      @suites     = Suite.find(suites_ids)
    end

    params[:init_date]=(params[:filter] && params[:filter][:init_date]) ? DateTime.strptime(params[:filter][:init_date], "%d.%m.%Y %H:%M"): 
DateTime.now.in_time_zone
    params[:finish_date]= params[:filter] && params[:filter][:finish_date]? DateTime.strptime(params[:filter][:finish_date], "%d.%m.%Y %H:%M") : DateTime.now.in_time_zone + (1*24*60*60) #1 day after    
    @weekly_trans = {"Sunday"=>_("Sunday"),"Monday"=>_("Monday"),"Tuesday"=>_("Tuesday"),"Wednesday"=>_("Wednesday"),"Thursday"=>_("Thursday"),"Friday"=>_("Friday"),"Saturday"=>_("Saturday")}

    #DelayedJobs
    @delayed_jobs = TaskProgram.filter(params)

    #TODO: arreglar el finde de DJs
    @delayed_jobs = DelayedJob.all.paginate :page => params[:page], :per_page =>10
  
    #TODO: IN NEW VIEW 
    #Cron
    @crons = Cron.all    

  end

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
    @text_error   = TaskProgram.validate(params)   
    @text_confirm = ''
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
     @text_error = TaskProgram.validate(params)   
     params[:execution][:server_port] = request.port if request.port != 80
     @user_configuration = current_user.user_configuration
     @user_configuration.update_configuration(params[:execution])
     TaskProgram.create_all(params)
     redirect_to "/task_programs" 
  end


  def delete
    @job = DelayedJob.find params[:id]
    if current_user.has_role?("root") or @job.task_program.user_id == current_user.id
      @job.destroy
      redirect_to "/task_programs"
    else
      redirect_to "/users/access_denied?source_uri=task_programs"
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


  def confirm_program
    @task_program  = TaskProgram.find params[:id]
    @confirm       = params[:confirm]? params[:confirm] : false
    @delayed_jobs  = @task_program.delayed_jobs.paginate :page => params[:page], :per_page => 14, :order => 'run_at ASC'
    @weekly_trans  = {"Sunday"=>_("Sunday"),"Monday"=>_("Monday"),"Tuesday"=>_("Tuesday"),"Wednesday"=>_("Wednesday"),"Thursday"=>_("Thursday"),"Friday"=>_("Friday"),"Saturday"=>_("Saturday")}    
  end
  
  def save_confirm_program
    @task_program = TaskProgram.find params[:id]
    #Schedules are confirmed as of today up to one month 
    @task_program.confirm_delayed_jobs_until(DateTime.now >> 1)
    redirect_to :action => :confirm_program, :id => @task_program.id, :confirm => true
  end


  def get_task_programs
      #Scheduled suites are obtained
      suites_ids = TaskProgram.find(:all, :conditions =>["project_id = ? and user_id = ?",params[:project_id],current_user.id]).map(&:suite_id).uniq
      suites = Suite.find_all_by_id(suites_ids)
      render :partial => "task_program_list" , :locals=>{:suites=>suites}  
  end
  
  def get_task_program_detail
        #Get all task program for the suite
        task_programs = TaskProgram.find_all_by_suite_id params[:program][:suite_id]
        task_program_info = Hash.new
        task_programs.each do |tp|
          #Get name of suite and the next expiration
          next_expiration = tp.delayed_jobs.find_by_status 0
          task_program_info[tp.id] = next_expiration if next_expiration
        end
      render :partial => "task_program_detail" , :locals=>{:task_program_info=>task_program_info}          
  end
  
end


