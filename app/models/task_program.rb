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
 
class TaskProgram < ActiveRecord::Base
  unloadable
  belongs_to :user 
  belongs_to :suite
  belongs_to :project  
  has_many :delayed_jobs, :dependent => :destroy
  
  validates_presence_of :user_id,    :message => _("Must complete User Field")
  validates_presence_of :suite_id,   :message => _("Must complete suite")
    
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

   
end
