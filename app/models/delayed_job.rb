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
  
end
