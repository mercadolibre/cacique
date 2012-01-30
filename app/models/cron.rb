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

 #
 #  @Authors:    
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
 
 class Cron < ActiveRecord::Base

  belongs_to :task_program, :dependent => :destroy
  validates_presence_of :task_program_id, :message => _("Must complete task program")
 
  #Create new Cron and update server cron
  def self.add(task_program, cron_params)

    #Cron new
    cron = Cron.create( {:task_program_id=>task_program.id}.merge(cron_params) )

    #Generate command
    command = cron.build_command(task_program.execution_params.params)
    
    #Generate file code 
    code = cron.add_line(command)

    #Update and execute file (SSH)
    cron.update_file(code)
  end

  #Remove Cron and update server cron
  def self.remove(id)

    #Find cron
    cron = Cron.find id.to_i

    #Generate file code 
    code = cron.remove_line

    #Update and execute file (SSH)
    cron.update_file(code)

    #Cron destroy
    cron.destroy

  end

  def build_command(execution_params)
      command = SuiteExecution.generate_command(execution_params) 
      command.gsub!("\<user_name\>",FIRST_USER_NAME)#UserName
      command.gsub!("\<user_pass\>",FIRST_USER_PASS)#UserPass
      "#{RAILS_ROOT}/lib/#{command}"
  end

  def add_line(command)
      code      = "require 'rubygems'\n require 'cronedit'\n include CronEdit\n\n"
      frecuency = "#{self.min} #{self.hour} #{self.day_of_month} #{self.month} #{self.day_of_week}"
      code      + "Crontab.Add  'program_#{self.id}', '#{frecuency}  #{command}'" 
  end

  def remove_line
      code = "require 'rubygems'\n require 'cronedit'\n include CronEdit\n\n"
      code + "Crontab.Remove 'program_#{self.id}'"
  end

  def update_file(code)
    require 'net/ssh'

    #SSH copy & run
    Net::SSH.start(SERVER_CRON, USER_SERVER_CRON, :password =>PASS_SERVER_CRON) do |ssh|

      #Generate File
      file_name="program_#{self.id}.rb"
      ssh.exec "echo -e \"#{code}\" > #{DIRECTORY_SERVER_CRON + file_name}" 
          
      #Run file
      ssh.exec! "ruby #{DIRECTORY_SERVER_CRON + file_name}"

      #Delete file
      ssh.exec! "rm #{DIRECTORY_SERVER_CRON + file_name}"

    end


  end

end
