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
require "#{RAILS_ROOT}/lib/runner/fake_oracle_logger.rb"
require "#{RAILS_ROOT}/lib/runner/selenium_logger.rb"
require "#{RAILS_ROOT}/lib/runner/webdriver_logger.rb"

class ScriptRunner < ActiveRecord::Base

  attr_accessor	:debug_mode
  attr_accessor :remote_control_addr
  attr_accessor :remote_control_port
  attr_accessor	:data
  attr_accessor	:ccq_return
  attr_accessor :output
  attr_accessor	:data_recoveries
  attr_accessor :project_id #to find required cacique functions
  attr_accessor :configuration_values
  attr_accessor :execution 
  attr_accessor :free_values
  attr_accessor :execution_flag
  attr_accessor :ccq_exec_flag
  require 'timeout'

  def initialize
    @ccq_functions = Array.new #Called functions list
    #This flag will be set if worker need to be rebooted
    @ccq_exec_flag=0 
    @ccq_return = Hash.new
    @output = String.new
    #This should must be set on all functions that cannot be stopped by the user
    @ccq_atomic = false
    #Stop script
    Signal.trap("SIGUSR2") do
      ccq_stop
      Timeout::timeout(ATOMIC_TIMEOUT) do
        while @ccq_atomic do end 
      end
      $ccq_execution_thread.kill 
    end
    #Marking worker for reboot
    Signal.trap("SIGUSR1") do
        @ccq_exec_flag=1
    end
  end

  #Script Run
  def run_source_code(ccq_file_code)
    #Se execution values
    execution.ip=local_ip
    execution.pid=$$
    execution.save
    Rails.cache.write WORKER_CACHE_KEY, execution
    #Method for the creation of the script
    ccq_generate_script(ccq_file_code)
    #Thread
		self.ccq_return = Hash.new
    $ccq_execution_thread=Thread.new do
      begin
	  	  #Run script header (Cacique user function)
		    initialize_run_script
	  	  #Run script
		    ccq_run_script_return =  ccq_run_script
			  ccq_return.merge! ccq_run_script_return if ccq_run_script_return.instance_of? Hash
		  rescue Exception => ccq_error
  		  ccq_error_handling(ccq_error, ccq_file_code)
  		ensure
        #Run script footer (#Cacique user function)
  			finalize_run_script
	    end
    end# Thread.new end
    $ccq_execution_thread.join
    return ccq_get_return_data
	end#run_source_code


  #To generate cacique's functions
  def method_missing(m,*x)
     UserFunction
     #Function is sought
     ccq_function = ccq_find_function(m) 
     #If found, is generated
     ccq_generate_function(ccq_function,x) if ccq_function 
  end

  # puts script manager. Adds to output log
  def print(*x)
		self.output << x.join
		super(*x)
  end

  def p(*args)
		args.each do |x|
		  self.print x.inspect,"\n"
		end
		nil
  end

  def puts(*args)
    args.each do |x|
		 self.print x,"\n" 
		end	
		nil
  end

  def reset_output
		@output = String.new
  end

  #only for obtain position_error variable, through an extend
  module PositionErrorHolder
    attr_accessor	:position_error
  end

  def evaluate_data( dat )
    return dat if dat.instance_of? String #Class String
    if dat.instance_of? Symbol #Class Symbol
      return self.data[dat] if self.data[dat] #Data set
      return dat #Symbol
    end
    if dat.instance_of? Hash #Class Hash
     return self.evaluate_data( dat[:default] ) if dat[:default]
     raise "No se puede encontrar cadena correspondiente al site para "+"#{dat.inspect}"
    end
    return dat.to_s if dat.instance_of? Fixnum or dat.instance_of? Bignum #Class Fixnum o Bignum
    return dat
  end

private

  def ccq_generate_script(file_code)
    #Get Data and eval
    eval(ccq_get_data_set)
    #Format checker
		ccq_generated_module_name = "M#{rand(100000000)}"
		# Generate code and eval
		eval(ccq_generate_code(ccq_generated_module_name, file_code ))
		# extend generated module
		extend eval(ccq_generated_module_name)
  end

  def ccq_get_data_set
    arguments_init_code  = ""
    #To use case_template directly, without data[:]
    self.data.each do |key,value|
      if !value.to_s.match(/autocompletar/).nil?
        #For if you send a function as data
  		  begin
          self.data[key] = eval(value)
        rescue
          self.data[key] = value
        end
      end
      arguments_init_code += "def self.#{key.to_s}; data[:#{key.to_sym}]; end\n" if key.to_s != "" and key != :execution_id
    end #data.each
    #add ContextConfiguration arguments
    self.configuration_values.each do |key,value|
      arguments_init_code += "def #{key.to_s}; if @#{key.to_s}; return @#{key.to_s}; else; return \"#{value}\"; end ; end\n"
    end
    return arguments_init_code
  end#ccq_get_data_set

  def ccq_generate_code(module_name, file_code)
    ccq_code = "module #{module_name}\n" +
		"	def ccq_run_script\n" +
		"		\n " +
		"		#{file_code}\n" +
		"		local_variables.each { |localvar|\n " +
		"			 if data_recoveries[localvar.to_sym]\n" +
		"			   self.ccq_return[localvar.to_sym] = eval(localvar)\n" +
		"			 end\n" +
    "      ccq_automatic_data_recoveries do |code_| eval(code_) end\n" +
		"		}\n" +
		"	end\n" +
		"end\n"
    return ccq_code
  end

  #Hash generated with recovery data in every script execution
  def ccq_automatic_data_recoveries
		self.data_recoveries.each do |key,code|
			if code
		    unless self.ccq_return[key]
			    begin
					 self.ccq_return[key] = yield(code)
		      rescue Exception => error
					  raise _("Processing Data Error ")+"'#{key}' (#{code}): #{error.to_s}"
				  end
        end
		  end
		end
		ccq_return
	end

  def ccq_stop
    self.execution_flag=1#Marking for stop
    self.execution.status=6#Stopped
    self.execution.save
    Rails.cache.write "exec_#{self.execution.id}", self.execution
  end

  def ccq_error_handling(stack, code)
    Rails.cache.delete WORKER_CACHE_KEY
	  error_run_script#Cacique user function
		stack.extend PositionErrorHolder
    error = ccq_parser_error(stack, code)
    #Error
		raise error
  end

  def ccq_parser_error(stack, code)
    error = ""
    called_functions = ""
    called_functions = "\n Called functions:\n" + @ccq_functions.join("\n")  if !@ccq_functions.empty?

    #ERROR: Delete "ccq_" errors
    error = stack.message.split("\n").select{ |str| str =~ /(eval)/ and  !str.match(/ccq_/) } if error.empty?
    error = stack if error.empty? #Function Raise 

    #Detele Cacique paths
    error.to_s.gsub!(/(\/\w+)*.\w+:\d+:in `ccq_\w+':/, "")
    #Delete multiple \n
    error.to_s.gsub!(/\n(\s)*\n/,"\n")

    #LINE
      #Get all "(eval)" lines
      trace = stack.backtrace.select{ |str| str =~ /^\(eval\)/ }
      trace.each do |line|
        #If Script error: error line -3
        if line.match(/ccq_run_script/)
          line_number = line.split("(eval):")[1].split(":")[0].to_i - 3 
          line.sub!(/\(eval\):(\d)*:/, "(eval):#{line_number.to_s}:")
          line.gsub!("ccq_run_script", self.execution.circuit.name) 

          #Trace script code, range lines:[error line -2 , error line + 2]
  		    begin_trace = line_number - 2 #Line error - 2 lines
  		    begin_trace = begin_trace < 0 ? 0 : begin_trace
    		  lnum = begin_trace
          range_lines = code.split("\n")[begin_trace..begin_trace+5]
    		  trace << "\n\n" + range_lines.map{|x| "#{lnum == (line_number - 1) ? " * " : ""}#{ (lnum+=1) }: #{x}" }.join("\n") + "..." if range_lines
        end

        #Function error 
        line.gsub!("ccq_generate_function", @ccq_functions.first) if !@ccq_functions.empty?
        #Detele Cacique paths
        line.gsub!(/(\/\w+)*.\w+:\d+:in `ccq_\w+':/, "")
      end

    error  = " #{trace} \n #{ called_functions } ---> Error: <--- #{error} "
    error
  end


  def ccq_get_return_data
		return_aux = Hash.new
		self.ccq_return.each do |k,v| return_aux[k.to_s] = v end
    #add arguments to returned data
    self.data.each do |key,value|
      # the returned data have priority over parameters --
      # returned data checker
      unless return_aux.has_key? key.to_s
          return_aux[key.to_s] = value
      end
    end
		return return_aux
  end


  ####################################### User Functions ######################################
  def ccq_find_function(function_name)
     #I search the function in cache
     function = Rails.cache.read "function_#{function_name.to_s}"
     if !function
        #if is an uncached function, looked in function array
        functions = Rails.cache.fetch("functions"){ UserFunction.hash_to_load_cache }
        if functions.include?(function_name.to_s)
          #if exists, but not cached, I search it in db and caching
          function = UserFunction.find_by_name(function_name.to_s)
          Rails.cache.write("function_#{function_name.to_s}", function, :expires_in => CACHE_FUNCTIONS)
        end
     end
     if !function
       stack = _(" Method not found: ")+ "#{function_name.to_s}\n "
       raise stack
    end
    return function
  end


  def ccq_generate_function(function, arguments)
    #Verify permissions
    if ccq_verify_function_permissions(function)
      #Search the object to add the function
	    new_object = ObjectSpace._id2ref(self.object_id)
      #Add function to the called functions list
      @ccq_functions.push(function.name)
      #Eval function
      begin 
  	    #Define function to finded object
        eval(function.source_code)
  	     #Call fucntion with script params
        if function.native_params
          #Call fucntion with script params
          eval_return =  eval( "new_object.method(function.name.to_sym).call(*arguments)" )
        else
          args = arguments.map{|argument| "#{ccq_to_ruby_expr(argument)}"}.join(",")
  	      eval_return  = eval("new_object." + function.name.to_s+ "("+args+")")
        end
        @ccq_functions.pop
        eval_return 
      rescue => error
        stack = " \n  #{error}  \n"
        raise stack
      end
    end
  end

  def ccq_verify_function_permissions(function)
    if !(function.project_id == self.project_id.to_i or function.visibility or function.project_id == 0)
      stack = _(" You are not authorized to perform the function ") + " #{function.name.to_s} (" + _('Project:') + " #{function.project.name})"
      #Error
      raise stack
    else
      return true
    end
  end

	def ccq_to_ruby_expr(value)
	  return "#{value}" if(value.class == Fixnum)
		return "\"#{value.to_s.gsub("\\","\\\\\\\\").gsub("\"","\\\"").gsub("\#","\\\#") }\""
	end

end

