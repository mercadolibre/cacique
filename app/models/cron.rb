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
  before_save :task_program_id_validation

  validates_format_of :min, 
    :with => /^(\s)*(\*)(\s)*$|^((\s)*[0-9]|[0-3]?[0-1](\s)*)([-,\/,\,](\s)*[0,9]|[0-3]?[0-1](\s)*)*$/,
    :message => "Min error"

  validates_format_of :hour, 
    :with => /^(\s)*(\*)(\s)*$|^((\s)*[0-9]|[0-2]?[0-3](\s)*)([-,\/,\,](\s)*[0,9]|[0-2]?[0-3](\s)*)*$/,
    :message => "Hour error" 

  validates_format_of :day_of_month, 
    :with => /^(\s)*(\*)(\s)*$|^((\s)*[0-9]|[1-3]?[0-1](\s)*)([-,\/,\,](\s)*[0,9]|[1-3]?[0-1](\s)*)*$/,
    :message => "day_of_month" 

  validates_format_of :month, 
    :with => /^(\s)*(\*)(\s)*$|^((\s)*[0-9]|[1-1]?[0-2](\s)*)([-,\/,\,](\s)*[0,9]|[1-1]?[0-2](\s)*)*$/,
    :message => "month" 

  validates_format_of :day_of_week, 
    :with => /^(\s)*(\*)(\s)*$|^((\s)*[0-6](\s)*)([-,\/,\,](\s)*[0,6](\s)*)*$/,
    :message => "day_of_week" 

  def task_program_id_validation
    if !TaskProgram.exists?(task_program_id)
      errors.add("task_program_id", "Must complete valid task program")
    end
  end

  #Create new Cron and update server cron
  def self.add(task_program, cron_params)

    #Cron validations
    cron = Cron.new(cron_params)
    if cron.valid?

      #TaskProgram.save
      task_program.save

      #Cron new 
      cron.task_program_id=task_program.id
      cron.save

      #Generate command (using cron.id generated)
      command = cron.build_command
      
      #Generate file code 
      code = header_line + cron.add_line(command)

      #Update and execute file (SSH)
      cron.update_file(code)

    end
    cron   
  end

  #Remove Cron and update server cron
  def self.remove(id)
    cron_ids = id.to_a
    cron_ids.each do |id|
      #Find cron
      cron = Cron.find id.to_i
      #Generate file code 
      code = header_line + cron.remove_line
      #Update and execute file (SSH)
      cron.update_file(code)
      #Cron destroy
      cron.destroy
    end
  end

  #Builds Cacique command 
  def build_command
      command = SuiteExecution.generate_command(self.task_program.execution_params) 
      "#{RAILS_ROOT}/lib/#{command}"
  end

  #Generates the line with the requires
  def self.header_line
    "require 'rubygems'\n require 'cronedit'\n include CronEdit\n\n"
  end

  #Generates the line Crontab.Add
  def add_line(command)
      frecuency = "#{self.min} #{self.hour} #{self.day_of_month} #{self.month} #{self.day_of_week}"
      "Crontab.Add  'program_#{self.id}', '#{frecuency}  #{command}'\n" 
  end

  #Generates the line Crontab.Remove
  def remove_line
      "Crontab.Remove 'program_#{self.id}'\n"
  end

  #Updates the machine charge for performing the task scheduling
  #1) Generate ssh connection to the machine
  #2) File is generated with the changes (File CronEdit)
  #3) Run the generated file before
  def update_file(code)
    require 'net/ssh'

    begin
      #SSH copy & run
      Net::SSH.start(SERVER_CRON, USER_SERVER_CRON, :password =>PASS_SERVER_CRON) do |ssh|

        #To test validate cronEdit run: 
        #code =  "require 'rubygems'\n require 'cronedit'\n include CronEdit\n\n Crontab.Add 'agent1', '1 999 * * * ls'"

        #Generate File
        file_name="program_#{self.id}.rb"
        output = ssh.exec! "echo -e \"#{code}\" > #{DIRECTORY_SERVER_CRON + file_name}" 
                    
        #Validate Generate File
        #Fail DIRECTORY_SERVER_CRON
        raise "No such file or directory. Please verify DIRECTORY_SERVER_CRON" if output and output.match(/No such file or directory/) 
        #Others errors
        raise "#{output}" if output

        #Run file
        output = ssh.exec! "ruby #{DIRECTORY_SERVER_CRON + file_name}"

        #Validate Run file
        raise "Error processing cron file. #{output}" if output

        #Delete file
        ssh.exec! "rm #{DIRECTORY_SERVER_CRON + file_name}"
      end

    #Conexion errors
    rescue Exception => error 
      raise "CRONEDIT ERROR: AuthenticationFailed #{error.to_s}. Please verify SERVER_CRON, USER_SERVER_CRON and PASS_SERVER_CRON" if error.class == Net::SSH::AuthenticationFailed
      raise "CRONEDIT ERROR: #{error.to_s}"
    end
  end

  #Regenerate the programming of the machine charge 
  #for carrying out the task scheduling
  # 1) Clear all crons
  # 2) Generate all crons from db 
  def self.regenerate

    #Find all crons
    crons = Cron.all

    #Generate all lines to add crons
    lines_to_add_crons = ""
    crons.each do |cron|
      #Generate command
      lines_to_add_crons += cron.add_line(cron.build_command)
    end

    # Generate file code to: Clear all + Create all 
    code = header_line + clear + lines_to_add_crons

    #Update and execute file (SSH)
    crons.first.update_file(code)

  end

  def self.clear
    "cm = Crontab.new\ncm.clear!\n\n"
  end
end
