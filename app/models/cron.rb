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

  belongs_to :task_program
  validates_presence_of :task_program_id, :message => _("Must complete task program")
 
  def add(execution_params)
    #Generate command
    command = build_command(execution_params)
    
    #Generate file code 
    code = add_line(command)

    #Update and execute file (SSH)
    update_file(code)
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
      code      + "Crontab.Add  :#{self.id}, '#{frecuency}  #{command}'" 
  end

  def remove_line
      code = "require 'rubygems'\n require 'cronedit'\n include CronEdit\n\n"
      code + "Crontab.Remove  :#{self.id}"     
  end

  def update_file(code)

    #Generate File
    file_name="#{RAILS_ROOT}/tmp/program_#{self.id}.rb"
    File.delete(file_name) if File.exists?(file_name)
    File.open(file_name, 'w') {|f| f.write(code) }

    #TODO:
    #SSH copy
    #SSH run
    #Delete file
    #File.delete(file_name)
  end

end
