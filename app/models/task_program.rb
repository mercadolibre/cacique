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

# == Schema Information
# Schema version: 20110630143837
#
# Table name: task_programs
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  suite_execution_ids :text
#  suite_id            :integer(4)
#  project_id          :integer(4)
#  created_at          :datetime
#  updated_at          :datetime
#  identifier          :string(50)      default(" ")
# 
class TaskProgram < ActiveRecord::Base
  unloadable
  belongs_to :user 
  belongs_to :project
  has_and_belongs_to_many :suites
  has_many :delayed_jobs, :dependent => :destroy
  has_many :crons, :dependent => :destroy
  validates_presence_of :user_id,    :message => _("Must complete User Field")
  serialize :execution_params

  def self.create_all(params)
    Suite

    #CronEdit
    if params[:program][:range] == "forever"

      #Build execution params
      params[:execution][:identifier] = _('Schedule') if params[:execution][:identifier].empty?

      #TaskProgram new
      task_program = TaskProgram.new({ :user_id => current_user.id,
                                        :suite_execution_ids => "", 
                                        :project_id => params[:project_id],
                                        :identifier=> params[:execution][:identifier],
                                        :execution_params=> params[:execution]
                                      })
      #Suites                                           
      params[:execution][:suite_ids] = Suite.find_all_by_project_id(params[:project_id]).map(&:id)  if params[:execution][:suite_ids].include?("0") 
      task_program.suites << Suite.find( params[:execution][:suite_ids].split(',') )

      #Cron create => task_program create
      cron = Cron.add(task_program, params[:cron])

      #TODO: show erros in view
      raise cron.errors.full_messages.to_s if !cron.errors.empty?

    #DelayedJob
    else
      times_to_run = TaskProgram.generate_times_to_run(params[:program])
      #Returns in the format [[time, status],[time, status]]
      #Por ex. [[Time0,0],[Time1,1],[Time2,0]]

      #Suites
      params[:execution][:suite_ids] = Suite.find_all_by_project_id(params[:project_id]).map(&:id)  if params[:execution][:suite_ids].include?("0") 
      run = TaskProgram.calculate_status(times_to_run)
      params[:execution][:delayed_job_status] = 1

      #TaskProgram new
      task_program = TaskProgram.create({:user_id => current_user.id,
                                            :suite_execution_ids => "", 
                                            :project_id => params[:project_id],
                                            :identifier=> params[:execution][:identifier]
                                            })
      task_program.suites << Suite.find( params[:execution][:suite_ids].split(',') )

      #Build execution params
      params[:execution][:identifier]      = _('Schedule') if params[:execution][:identifier].empty?
      params[:execution][:task_program_id] = task_program.id
      params[:execution][:user_mail]       = current_user.email
      params[:execution][:user_id]         = current_user.id
 
      #server_port is used to send the confirmation mail schedules if DelayedJob have status = 2
      run.each do |r|
        DelayedJob.create_run(params[:execution], r[0], r[1], task_program.id)
      end
    end
  end

  
  #builds all agreed on the basis of "params" and assembles the "delayed job" for
  def self.generate_times_to_run(params)
    times_to_run = Array.new #Dates to generate delayed jobs 
    case params[:range]
      when "today"
        date = params[:one_date].to_time
        times_to_run = times_to_run + program_repeat(params, date) #Repeats execution
      when "extend"
        case params[:frecuency]
          when "daily"  
             frecuency_init_date   = params[:init_date].to_time
             frecuency_finish_date = params[:finish_date].to_time  
             daily_date            = frecuency_init_date
             while(daily_date.in_time_zone <= frecuency_finish_date.in_time_zone ) do
               times_to_run = times_to_run + program_repeat(params, daily_date) #Repeats execution
               daily_date = daily_date +  60*60*24 #Add one day
             end
         when "weekly"     
             weekly_init_date_aux = params[:init_date].to_time
             weekly_finish_date   = params[:finish_date].to_time             
             days_of_week         = params[:week_days]
             #Build the init date
             weekly_init_date = Time.local(weekly_init_date_aux.year, weekly_init_date_aux.month, weekly_init_date_aux.day,  '00', '00', '00')
             weekly_date      = weekly_init_date
             while(weekly_date.in_time_zone  <= weekly_finish_date.in_time_zone) do
               #Get the first valid date
               weekly_date  = get_next_valid_date(days_of_week, weekly_date , weekly_finish_date )
               times_to_run = times_to_run + program_repeat(params, weekly_date )
               weekly_date  = weekly_date +  60*60*24 #Add one day
             end        
         end
      when "forever"
         times_to_run << params[:cron]
      else
        raise "Indefined range"
    end#End case params[range]
    return times_to_run
  end
  
  def  self.program_repeat(params, date)
    times_to_run = Array.new
    init_hour     = params[:init_hour].split(':')[0]  
    init_min      = params[:init_hour].split(':')[1]  
    runs          = params[:runs].to_i
    if  runs > 1 
       case params[:range_repeat]
            when "each"
                per_each =  params[:per_each].to_i
                #Build the init date
                per_each_init_date = Time.local(date.year, date.month, date.day, init_hour, init_min, '00')
                #Each hours or minutes
                if params[:each_hour_or_min] == "min" #Minutes   
                     type_time = 60     #Add the selected minutes to the date             
                else #hours
                     type_time = 60*60 #Add the selected hours to the date
                end
                runs.times do |i|
                  times_to_run << per_each_init_date
                  per_each_init_date = per_each_init_date + per_each * type_time
                end
            when "specific"
              runs.times do |nro|
                  input_name   = "specific_hour_" + nro.to_s 
                  #Get the init_hour for the specific run
                  hour_and_min = params[input_name.to_sym]
                  hour         = hour_and_min.split(':')[0]
                  minutes      = hour_and_min.split(':')[1]
                  #Build the init date
                  times_to_run << Time.local(date.year, date.month, date.day, hour,  minutes , '00')
              end
            else          
              raise "Indefined range"
          end#End case params[:range_each] 
   else
     times_to_run << Time.local(date.year, date.month, date.day, init_hour, init_min, '00') 
   end#End runs
   return times_to_run

  end
  
  def self.get_next_valid_date(valid_dates, date, finish)
    valid_date = date
    while(valid_date.in_time_zone <= finish.in_time_zone) do
      return valid_date if valid_dates.include?(valid_date.strftime("%A")) 
      valid_date = valid_date +  60*60*24
    end
    return finish
  end
  
  
  #Calculate status for delayed jobs 
  def self.calculate_status(times_to_run)
    times_with_status = Array.new #Array format: [ [time1, status1], [time2, status2] ]
    init_date = times_to_run[0]
    finish    = init_date.to_datetime >> 1 #Finish: next month (30 days) 
    mark      = 0 # Brand position confirmation
    pos       = 0 
    set_mark  = false #If the program exceeded the month, must set the mark
    times_to_run.each do |time|
       if(time.in_time_zone <= finish.in_time_zone)
           times_with_status << [time, 1]
           mark = pos
       else
           times_with_status << [time, 0]
           set_mark = true         
       end
       pos+=1
     end
     #Set confirmation mark (status 2)
     times_with_status[mark][1] = 2 if set_mark
     return times_with_status
  end
  
  def add_suite_execution_id(suite_execution_id)
    if self.suite_execution_ids.empty?
      self.suite_execution_ids += suite_execution_id.to_s
    else
      self.suite_execution_ids += "," + suite_execution_id.to_s
    end
    self.save
  end
  
  
  def find_previous_program(delayed_job_id)
    runs = self.delayed_jobs.order(:run_at).reverse
    runs.each do |delayed_job|
        runs.delete(delayed_job)
        break if delayed_job.id == delayed_job_id.to_i
    end
    return runs.first
  end
  
  
  def find_next_program(delayed_job_id)
    runs = self.delayed_jobs.order(:run_at)
    runs.each do |delayed_job|
        runs.delete(delayed_job)
        break if delayed_job.id == delayed_job_id.to_i
    end
    return runs.first
  end
  
 #Change the states of all the programming jobs delayed until the day of the parameter
 def confirm_delayed_jobs_until(until_time)
    #Change the states of the programming with states 2
    dj = self.delayed_jobs.find_by_status(2)
    if !dj.nil?
      dj.status = 0
      dj.save
    end
    delayed_jobs = self.delayed_jobs.find(:all, :conditions=>["run_at <= ?", until_time.in_time_zone])

    if !delayed_jobs.empty?
       delayed_jobs.each do |dj|
          dj.status =  1   
          dj.save    
       end  
    #Establish the new confirmation
    delayed_jobs.last.status = 2
    delayed_jobs.last.save
   end 
 end


  def self.validate(params)
     #Select any Suite
     return _('Must Select any Suite')  if  !params[:execution][:suite_ids]
     #Time format
     return _('Invalid Time Format for Init Hour. Please verify it.') if !params[:program][:init_hour].match(/\d{2}:\d{2}/)
     return _('Invalid Time Format. Time must be after the current.') if params[:program][:range]=="today" and  params[:program]["one_date"].to_date.today? and params[:program][:init_hour] < Time.now.strftime("%H:%M")
     #Identifier format
     params[:execution][:identifier].gsub!(" ","_")
     return _('Field ID must contain only letters, numbers, space or underscore') if params[:execution][:identifier].match(/^(\w*\_?)*$/).nil? and !params[:execution][:identifier].empty?
     #Repetitions 
     runs = params[:program][:runs].to_i
     period = params[:program][:range_each].to_s
     return _('Invalid Number of Repetitions')+_('. Please verify it.') if  runs  < 1 or params[:program][:runs].match(/\D/) or runs >500
     #Select any Weekly
     return _('Must select at least one day in your weekly schedule.') if params[:program][:frecuency]=="weekly" and !params[:program][:week_days]
     #[Until Date] should be after to [From Date]
     i_date = params[:program][:init_date].to_datetime
     f_date = params[:program][:finish_date].to_datetime
     return _('[Until Date] should be after to [From Date]') if params[:program][:range]=="extend" and i_date > f_date
   #Specific today
   if params[:program][:range]=="today" and period == "specific"
       runs.times do |nro|
         nr= nro.to_s
         input_name   = "specific_hour_" + nr 
         #Get the init_hour for the specific run
         hour_and_min = params[:program][input_name.to_sym]
         
         if !hour_and_min.match(/\d{2}:\d{2}/) or hour_and_min < Time.now.strftime("%H:%M")
         return _('Invalid Time Format for Execution No.: ')+ nr +_('. Please verify it.')
         end          
       end
   end  

   #Specific with runs >1    
   if  runs  > 1 and period == "specific"     
       runs.times do |nro|
         nr= nro.to_s
         input_name   = "specific_hour_" + nr 
         #Get the init_hour for the specific run
         hour_and_min = params[:program][input_name.to_sym]
         return _('Invalid Time Format for Execution No.: ')+ nr +_('. Please verify it.') if !hour_and_min.match(/\d{2}:\d{2}/)       
       end    
   else     
     #Per each      
     if runs  > 1 and period == "per_each"           
       return _('Invalid Number of repetitions per hour') +_('. Please verify it.') if !params[:program][:per_hour].match(/^([1-9]\d*|0(\d*[1-9]\d*)+)$/)
     end     
   end
   return ""

  end

  def self.sumarize_by_user_and_projects user, projects
    find(:all, :select => "*, count(suite_id) as executions",
         :conditions => ['user_id=? AND project_id IN (?)', user.id, projects], :group => 'suite_id')
  end


  def self.build_params
      params[:execution][:user_mail] = current_user.email
      params[:execution][:user_id]   = current_user.id
      params[:execution][:suite_id]  = (params[:execution][:suite_ids].include?("0")? Suite.find_all_by_project_id(params[:project_id]).map(&:id) : params[:execution][:suite_ids]).join(",")
      params
  end


  def self.filter(params)

    user_id  = (params[:filter] && params[:filter][:user_id])   ? params[:filter][:user_id].to_i    : 0 
    suite_id = (params[:filter] && params[:filter][:suite_id])  ? params[:filter][:suite_id].to_i   : 0

    #Bulid conditions
    conditions        = Array.new
    conditions_names  = Array.new
    conditions_values = Array.new

    if params[:project_id] != 0   
      conditions_names << " project_id = ? " 
      conditions_values << params[:project_id]
    end

    if user_id != 0   
      conditions_names << " user_id = ? " 
      conditions_values << user_id
    end

    if params[:filter] && params[:filter][:identifier] && !params[:filter][:identifier].empty?
      conditions_names << " identifier  like ? " 
      conditions_values << '%' + params[:filter][:identifier] + '%'
    end

    if @suite_id != 0
      conditions_names << " suite_id  = ? " 
      conditions_values << suite_id
    end

   conditions_names << " run_at BETWEEN ? AND ? " 
   conditions_values << params[:init_date].strftime("%y-%m-%d %H:%M:%S")   
   conditions_values << params[:finish_date].strftime("%y-%m-%d %H:%M:%S") 

   conditions << conditions_names.join("and")  
   conditions = conditions + conditions_values
   number_per_page=10
   number_per_page= params[:filter][:paginate].to_i if params[:filter] && params[:filter].include?(:paginate)

   delayed_jobs  = DelayedJob.find :all, :joins =>:task_program, :conditions=>conditions, :order => "run_at ASC"
   delayed_jobs.paginate :page => params[:page], :per_page => number_per_page
  
  end

end
