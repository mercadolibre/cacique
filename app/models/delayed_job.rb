# == Schema Information
# Schema version: 20110630143837
#
# Table name: delayed_jobs
#
#  id              :integer(4)      not null, primary key
#  priority        :integer(4)      default(0)
#  attempts        :integer(4)      default(0)
#  handler         :text
#  last_error      :text
#  run_at          :datetime
#  locked_at       :datetime
#  failed_at       :datetime
#  locked_by       :text
#  created_at      :datetime
#  updated_at      :datetime
#  task_program_id :integer(4)
#  status          :integer(1)      default(1)
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
require "#{RAILS_ROOT}/lib/run_suite_program.rb"
class DelayedJob < ActiveRecord::Base
  unloadable
  belongs_to :task_program
  validates_presence_of :task_program_id,   :message => _("Must complete task program")
  validates_presence_of :status,            :message => _("Must complete status")
  
  before_destroy :verify_status
  after_destroy :destroy_task_program

  def self.add( task_program, params)

      task_program.save

      times_to_run = TaskProgram.generate_times_to_run(params[:program])
      #Returns in the format [[time, status],[time, status]]
      #Por ex. [[Time0,0],[Time1,1],[Time2,0]]

      run = TaskProgram.calculate_status(times_to_run)
      params[:execution][:delayed_job_status] = 1

      #Build execution params
      params[:execution][:task_program_id] = task_program.id
      params[:execution][:user_mail]       = current_user.email
      params[:execution][:user_id]         = current_user.id
 
      #server_port is used to send the confirmation mail schedules if DelayedJob have status = 2
      run.each do |r|
        DelayedJob.create_run(params[:execution], r[0], r[1], task_program.id)
      end
  end

  def self.filter(params)

    user_id  = (params[:filter] && params[:filter][:user_id])   ? params[:filter][:user_id].to_i    : 0 
    suite_id = (params[:filter] && params[:filter][:suite_id])  ? params[:filter][:suite_id].to_i   : 0

    #Bulid conditions
    conditions        = Array.new
    conditions_names  = Array.new
    conditions_values = Array.new

    if params[:project_id] != 0   
      conditions_names << " task_programs.project_id = ? " 
      conditions_values << params[:project_id]
    end

    if user_id != 0   
      conditions_names << " task_programs.user_id = ? " 
      conditions_values << user_id
    end

    if params[:filter] && params[:filter][:identifier] && !params[:filter][:identifier].empty?
      conditions_names << " task_programs.identifier  like ? " 
      conditions_values << '%' + params[:filter][:identifier] + '%'
    end

    if suite_id != 0
      conditions_names << " suites.id  in (?)" 
      conditions_values << suite_id
    end

    conditions_names << " delayed_jobs.run_at BETWEEN ? AND ? " 
    conditions_values << params[:init_date].strftime("%y-%m-%d %H:%M:%S")   
    conditions_values << params[:finish_date].strftime("%y-%m-%d %H:%M:%S") 

    #Only confirmed
    conditions_names << " delayed_jobs.status in(?) " 
    conditions_values << [1,2]   

    conditions << conditions_names.join("and")  
    conditions = conditions + conditions_values

    task_programs = TaskProgram.find :all, :include=>[:suites, :delayed_jobs], :conditions=>conditions, :order => "identifier ASC"

    #Paginate
    number_per_page=10
    number_per_page= params[:filter][:paginate].to_i if params[:filter] && params[:filter].include?(:paginate)
    task_programs.paginate :page => params[:page], :per_page => number_per_page
    
  end

  def verify_status
     task_program = TaskProgram.find self.task_program_id
    if self.status == 2
      next_program = task_program.find_next_program(self.id)
      if next_program
        next_program.status = 2
        next_program.save
      else
        previous_program = task_program.find_previous_program(self.id)
        if previous_program
          previous_program.status = 2
          previous_program.save
        end
      end
    end
    
    true
  end
  
  def s_status
    case self.status
      when 0 
        return _("To be confirmed")
      when 1
        return _("Confirmed")
      when 2
        return _("Last Confirmed")
    end
  end
  
  def self.create_run(params, time, status, task_program_id)
    #Creo la programacion con params incompleto.
    dj = Delayed::Job.enqueue(RunSuiteProgram.new(params), 1, time)
    #Recupero el id de la programacion creada y lo agrego a params
    params[:delayed_job_id] = dj.id
    
    job = DelayedJob.find dj.id
    job.task_program_id = task_program_id
    job.status = status
    job.handler = RunSuiteProgram.new(params)
    job.save
    return job 
  end
 
 
 def self.validate_params(params)

    #Repetitions 
    runs = params[:program][:runs].to_i
    period = params[:program][:range_each].to_s
    return _('Invalid Number of Repetitions')+_('. Please verify it.') if  runs  < 1 or params[:program][:runs].match(/\D/) or runs >500

    #Time format
    return _('Invalid Time Format for Init Hour. Please verify it.') if !params[:program][:init_hour].match(/\d{2}:\d{2}/)
    return _('Invalid Time Format. Time must be after the current.') if params[:program][:range]=="today" and  params[:program]["one_date"].to_date.today? and params[:program][:init_hour] < Time.now.strftime("%H:%M")

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

    return "" #Without errors
  end
 
  #If Delayed jobs is the last => destroy Task program
  def destroy_task_program
    task_program = self.task_program
    if task_program.delayed_jobs.count == 0
       task_program.destroy
    end
  end

end
