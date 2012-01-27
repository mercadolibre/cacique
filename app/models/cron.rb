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

  #belongs_to :task_program
  #validates_presence_of :task_program_id,   :message => _("Must complete task program")
 
   def update_file(execution_params)
	   self.build_command(execution_params)
	   #TODO: Ssh a la maquina que ejecutará en cron
   end

 	def build_command(execution_params)
    	command = SuiteExecution.generate_command(execution_params) 
    	command.gsub!("\<user_name\>",FIRST_USER_NAME)#UserName
        command.gsub!("\<user_pass\>",FIRST_USER_PASS)#UserPass
        text_command = "#{RAILS_ROOT}/lib/#{command}"
        #TODO: 
        #Crontab.Add  :DESDECACIQUE, text_dates + " " + self.frecuency
  end
end
