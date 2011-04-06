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
    #For filter
    @projects    = Project.all
    @users       = User.all   
    @suites      = Array.new 
    @user_id     = (params[:program] && params[:program][:user_id])   ? params[:program][:user_id].to_i    : 0 
    @project_id  = (params[:program] && params[:program][:project_id])? params[:program][:project_id].to_i : params[:project_id].to_i
    @suite_id    = (params[:program] && params[:program][:suite_id])  ? params[:program][:suite_id].to_i   : 0
    @init_date   = (params[:program] && params[:program][:init_date]) ? DateTime.strptime(params[:program][:init_date], "%d.%m.%Y %H:%M"): DateTime.now.in_time_zone
    @finish_date = params[:program] && params[:program][:finish_date]? DateTime.strptime(params[:program][:finish_date], "%d.%m.%Y %H:%M") : DateTime.now.in_time_zone >> 1 #One month later
    @weekly_trans  = {"Sunday"=>_("Sunday"),"Monday"=>_("Monday"),"Tuesday"=>_("Tuesday"),"Wednesday"=>_("Wednesday"),"Thursday"=>_("Thursday"),"Friday"=>_("Friday"),"Saturday"=>_("Saturday")}
    
    #One project selected
    if @project_id != 0 
         #Read suites ids from cache
         suites_ids = Rails.cache.read("project_suites_#{@project_id}")
         if !suites_ids
             #Read suites from db
             project = Project.find @project_id
             @suites= project.suites
             suites_ids = project.suite_ids
          #Read suites from cache
          else
             suites_ids.each do |suite_id|
                @suites << Rails.cache.fetch("suite_#{suite_id}"){Suite.find suite_id}
             end
         end
    #All projects
    else
      @suites = Suite.find :all
      suites_ids = @suites.map(&:id)
    end
    
    #Bulid conditions
    conditions        = Array.new
    conditions_names  = Array.new
    conditions_values = Array.new
    
    conditions_names << " run_at >= ? " 
    date = @init_date
    conditions_values << Time.local(date.year, date.month, date.day, date.hour, date.min, '00').getutc
    conditions_names << " run_at <= ? "    
    date = @finish_date
    conditions_values << Time.local(date.year, date.month, date.day, date.hour, date.min, '00').getutc
    if @user_id != 0   
      conditions_names << " user_id = ? " 
      conditions_values << @user_id
    end
    if @suite_id != 0
      conditions_names << " suite_id  = ? " 
      conditions_values << @suite_id
    elsif @project_id != 0 and @suite_id == 0       
      conditions_names << " suite_id  in (?) " 
      conditions_values << suites_ids
    end
   conditions << conditions_names.join("and")  
   conditions = conditions + conditions_values

   delayed_jobs  = DelayedJob.find :all, :joins =>:task_program, :conditions=>conditions, :order => "run_at ASC"
   @delayed_jobs = delayed_jobs.paginate :page => params[:page], :per_page => 11
  
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
      @suites       = Suite.find_all_by_project_id params[:project_id]
      @weekly       = Date::DAYNAMES 
      @weekly_trans = {"Sunday"=>_("Sunday"),"Monday"=>_("Monday"),"Tuesday"=>_("Tuesday"),"Wednesday"=>_("Wednesday"),"Thursday"=>_("Thursday"),"Friday"=>_("Friday"),"Saturday"=>_("Saturday")}
      @range_hours  = [ [_("Each"), "per_hours"], [_("Specify"),"specific"] ]
      @cell_selects = ContextConfiguration.build_select_data #Build the selects for edit cell

  end

  def create

      @text_error=""    
      
      program_validate(params)

      if !@text_error.empty?
        #@js = "top.location='/task_programs/new/#{params[:execution][:suite_id]}'; alert('#{@text_error}')"
        @js = "alert('#{@text_error}'); history.back();"
        render :inline => "<%= javascript_tag(@js) %>", :layout => true

      else

         params[:execution][:identifier] = "Suite_Programada" if params[:execution][:identifier].empty?
         params[:execution][:server_port] = request.port if request.port != 80
         times_to_run = TaskProgram.generate_times_to_run(params[:program])

         #Returns in the format [[time, status],[time, status]]
         #Por ex. [[Time0,0],[Time1,1],[Time2,0]]

         run = TaskProgram.calculate_status(times_to_run)
         params[:execution][:delayed_job_status] = 1
         task_program = TaskProgram.create({:user_id => current_user.id,
                                            :suite_execution_ids => "",
                                            :suite_id => params[:execution][:suite_id],
                                            :project_id => params[:project_id]})

         params[:execution][:task_program_id] = task_program.id
         params[:execution][:user_mail]       = current_user.email
         params[:execution][:user_id]         = current_user.id
         #server_port is used to send the confirmation mail schedules if DelayedJob have status = 2
         params[:execution][:server_port] = request.port
         run.each do |r|

            DelayedJob.create_run(params[:execution], r[0], r[1], task_program.id)
         #redirect_to "/task_programs?program[suite_id]=#{params[:execution][:suite_id]}" 
          end
         redirect_to "/task_programs?program[suite_id]=#{params[:execution][:suite_id]}"
       end

  end

  def delete()
    @job = DelayedJob.find params[:id]
    if current_user.has_role?("root") or @job.task_program.user_id == current_user.id
      @job.destroy
      redirect_to "/task_programs"
    else
      redirect_to "/users/access_denied?source_uri=task_programs"
    end
  end


 def program_validate(params)

   if !params[:program][:init_hour].match(/\d{2}:\d{2}/)
   @text_error=_('Invalid Time Format for Init Hour. Please verify it.')
   return false
   end
   
   if params[:program][:range]=="today" and params[:program][:init_hour] < Time.now.strftime("%H:%M")
   @text_error=_('Invalid Time Format. Time must be after the current.')
   return false
   end
 
   params[:execution][:identifier].gsub!(" ","_")
   if params[:execution][:identifier].match(/^(\w*\_?)*$/).nil? and !params[:execution][:identifier].empty?
   @text_error=_('Field ID must contain only letters, numbers, space or underscore')
   return false
   end

   cant_corridas = params[:program][:cant_corridas].to_i
   period = params[:program][:range_hours].to_s

     if  cant_corridas  < 1 or params[:program][:cant_corridas].match(/\D/) or cant_corridas >500
       @text_error=_('Invalid Number of Repetitions')+_('. Please verify it.')
       return false
     
     end
     
     
     if params[:program][:frecuency]=="weekly" and !params[:program][:week_days]
       @text_error=_('Must select at least one day in your weekly schedule.')
       return false
     end
     
     
   i_date = params[:program][:init_date].to_datetime
   f_date = params[:program][:finish_date].to_datetime
     
     if params[:program][:range]=="extend" and i_date > f_date
       @text_error=_('[Until Date] should be after to [From Date]')
       return false
     end
     
   
   if params[:program][:range]=="today" and period == "specific"
       cant_corridas.times do |nro|
         nr= nro.to_s
         input_name   = "specific_hour_" + nr 
         #Get the init_hour for the specific run
         hour_and_min = params[:program][input_name.to_sym]
         
         if !hour_and_min.match(/\d{2}:\d{2}/) or hour_and_min < Time.now.strftime("%H:%M")
         @text_error=_('Invalid Time Format for Execution No.: ')+ nr +_('. Please verify it.')
         return false
         end          
       end
   end
     
    
   if  cant_corridas  > 1 and period == "specific"     

       cant_corridas.times do |nro|
         nr= nro.to_s
         input_name   = "specific_hour_" + nr 
         #Get the init_hour for the specific run
         hour_and_min = params[:program][input_name.to_sym]
         
         if !hour_and_min.match(/\d{2}:\d{2}/)
         @text_error=_('Invalid Time Format for Execution No.: ')+ nr +_('. Please verify it.')
         return false
         end          
       end
     
   else   
         
     if cant_corridas  > 1 and period == "per_hours"           
       if !params[:program][:per_hour].match(/^([1-9]\d*|0(\d*[1-9]\d*)+)$/)
       @text_error=_('Invalid Number of repetitions per hour') +_('. Please verify it.')
       return false
       end
     end     
   end



 end


  def show_suites_of_project
    if params[:program][:project_id] == ''
      @suites = Suite.find :all
    else
      project = Project.find params[:program][:project_id]
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
          next_expiration = tp.delayed_jobs.find_by_status 2
          task_program_info[tp.id] = next_expiration if next_expiration
        end
      render :partial => "task_program_detail" , :locals=>{:task_program_info=>task_program_info}          
  end
  
end


