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
  before_save :task_program_id_validation
  before_destroy :remove

  validates_format_of :min, :hour, :day_of_month, :month, :day_of_week, :with => /^(\s)*(\*)(\s)*$|^(\s)*[0-9]+(\s)*([-,\/,\,](\s)*[0-9]+(\s)*)*$/,  :message => "Invalid format"
  validates_each :min, :hour, :day_of_month, :month, :day_of_week do |record, attr, value|
    value.gsub!(" ", "") #without spaces
    if value != "*"
      #Numbers
      values   = value.split(/,|\/|-/).map{|x| x.to_i}
      case attr
        when :min
          range = (0..59)
        when :hour
          range = (0..23)      
        when :day_of_month
          range = (1..31)          
        when :month
          range = (1..12)   
        when :day_of_week
          range = (0..6)                     
      end 
      errors = values.select{|x| !range.include?(x)}  
      record.errors.add attr, errors.join(', ') if !errors.empty?
    end
  end
 
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
  def remove
    #Generate file code 
    code = Cron.header_line + self.remove_line
    #Update and execute file (SSH)
    self.update_file(code)
  end

  def self.filter(params)

    user_id  = (params[:filter] && params[:filter][:user_id])   ? params[:filter][:user_id].to_i    : 0 
    suite_id = (params[:filter] && params[:filter][:suite_id])  ? params[:filter][:suite_id].to_i   : 0
    identifier  = params[:filter] && params[:filter][:identifier] && !params[:filter][:identifier].blank? ? params[:filter][:identifier] : nil

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

    if identifier
      conditions_names << " task_programs.identifier  like ? " 
      conditions_values << '%' + identifier + '%'
    end

    if suite_id != 0
      conditions_names << " suites.id  in (?)" 
      conditions_values << suite_id
    end

   conditions << conditions_names.join("and")  
   conditions = conditions + conditions_values

   crons = Cron.find :all, :include=>[:task_program=>:suites], :conditions=>conditions, :order => "task_programs.identifier ASC"

    #Paginate
    number_per_page=10
    number_per_page= params[:filter][:paginate].to_i if params[:filter] && params[:filter].include?(:paginate)
    crons.paginate :page => params[:page], :per_page => number_per_page
    
  end

  #Builds Cacique command 
  def build_command(user=nil)
      command = SuiteExecution.generate_command(self.task_program.execution_params, "cron", user) 
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
      text_error = "CRONEDIT ERROR: AuthenticationFailed #{error.to_s}. Please verify SERVER_CRON, USER_SERVER_CRON and PASS_SERVER_CRON (cacique_conf.rb)" 
      text_error += ".  -> Please refresh the list of alarms from the admin <- "
      Notifier.deliver_notifier_error(text_error)
    end
  end

  #Regenerate the programming of the machine charge 
  #for carrying out the task scheduling
  # 1) Clear all crons
  # 2) Generate all crons from db 
  def self.regenerate

    #Find all crons
    crons = Cron.all
    unless crons.empty?

      #Generate all lines to add crons
      lines_to_add_crons = ""
      
      crons.each do |cron|
        #Generate command
        lines_to_add_crons += cron.add_line(cron.build_command(cron.task_program.user))
      end

      # Generate file code to: Clear all + Create all 
      code = header_line + clear + lines_to_add_crons

      #Update and execute file (SSH)
      crons.first.update_file(code)
    end
  end

  #Clear all crons code
  def self.clear
    "cm = Crontab.new\ncm.clear!\n\n"
  end

 def self.validate_params(params)
    cron = Cron.new(params)
    return cron.errors.full_messages.join(', ') if !cron.valid?
    return ""
 end

end
