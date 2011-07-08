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
require "#{RAILS_ROOT}/lib/runner/wrapper_selenium.rb"
require "#{RAILS_ROOT}/lib/runner/fake_selenium_logger.rb"
require "#{RAILS_ROOT}/lib/runner/fake_oracle_logger.rb"

class ScriptRunner < ActiveRecord::Base

  attr_accessor	:debug_mode
	attr_accessor :remote_control_addr
	attr_accessor :remote_control_port
	attr_accessor	:data
	attr_accessor	:devuelve
	attr_accessor :output
	attr_accessor	:data_recoveries
	attr_accessor :project_id #to find required cacique functions
  attr_accessor :configuration_values
  attr_accessor :execution 
  attr_accessor :free_values
  attr_accessor :execution_flag
  def initialize
		@devuelve = Hash.new
		@output = String.new
    Signal.trap("SIGUSR2") {$execution_thread.kill; self.stop}
	end
	
    #only for obtain position_error variable, through an extend
    module PositionErrorHolder
      attr_accessor	:position_error
    end
	
	
    def evaluate_data( dat )	
      #Class String
      return dat if dat.instance_of? String
		
      #Class Symbol
      return self.data[dat] if dat.instance_of? Symbol

      #Class Hash
	  if dat.instance_of? Hash
	     if dat[:default]
		    return self.evaluate_data( dat[:default] )
		 end
		 raise "No se puede encontrar cadena correspondiente al site para "+"#{dat.inspect}"
	  end
		
      #Class Fixnum o Bignum
	  return dat.to_s if dat.instance_of? Fixnum or dat.instance_of? Bignum

      return dat
	end
  #to generate cacique's functions
	def method_missing(m,*x)
	  UserFunction
	   #I search the function in cache
	   #function = UserFunction.find_by_name(m.to_s)
	   function = Rails.cache.read "func_0_#{m.to_s}"
	   if function.nil?
	     function = Rails.cache.read "func_#{project_id}_#{m.to_s}"
          if function.nil?
            #if is an uncached function, looked in function array
            func_hash = Rails.cache.fetch("functions"){ UserFunction.hash_to_load_cache }
            func_hash[self.project_id.to_s] = [] if func_hash[self.project_id.to_s].nil?
            if func_hash[self.project_id.to_s].include?(m.to_s)
              #if exists, but not cached, I search it in db and caching
              function = UserFunction.find_by_name(m.to_s)
              Rails.cache.write("func_#{project_id}_#{m.to_s}", function, :expires_in => CACHE_FUNCTIONS)
            elsif func_hash["0"].include?(m.to_s)
              #if exists, but not cached, I search it in db and caching
              function = UserFunction.find_by_name(m.to_s)
              Rails.cache.write("func_0_#{m.to_s}", function, :expires_in => CACHE_FUNCTIONS)
            end
          end
        end

       #If I find it
       if function
	     args = x.map{|a| "#{a.to_ruby_expr}"}.join(",")
  
	     #search the object to add the function
	     new_object = ObjectSpace._id2ref(self.object_id)
	   
	     #define function to finded object
         eval(function.source_code)
	   
	     #function run
	     eval("new_object." + m.to_s+"("+args+")")
	   else
        # follow for nested call to improve the error on stacked functions
        stack_error=[]
        caller.each do|stack|
          if stack.include?("eval") && !stack.include?("method_missing") && !stack.include?("run_script") && !stack.include?('in `eval')
             stack_error << stack
          end
        end
        stack=stack_error.reverse.join(" => ").gsub(/\(eval\)\:\d*\:in\s`/,"'")
        puts stack
        puts "-->" + _("Method not found: ")+"#{m.to_s} <--"
        raise "#{stack}\n -->" + _(" Method not found: ")+"#{m.to_s}"
	   end
	end
	
	#Script Run
	def run_source_code( file_code )
    execution.ip=local_ip
    execution.pid=$$
    execution.save
    Rails.cache.write WORKER_CACHE_KEY, execution
		#format checker
		generated_module_name = "M#{rand(100000000)}"

        #to use case_template directly, without data[:]
		arguments_init_code = ""
		data.each do |key,value|
		    if !value.to_s.match(/autocompletar/).nil?
		      #For if you send a function as data
		      begin
                data[key] = eval(value)
              rescue
                data[key] = value
              end
            end
			if key.to_s != "" and key != :execution_id
			   arguments_init_code += "def self.#{key.to_s}; data[:#{key.to_sym}]; end\n"
			end
		end

		#add ContextConfiguration arguments
        configuration_values.each do |key,value|
          arguments_init_code += "def #{key.to_s}; if @#{key.to_s}; return @#{key.to_s}; else; return \"#{value}\"; end ; end\n"
        end
        
		eval(arguments_init_code)	
		
		code = 	"module #{generated_module_name}\n" +
				"	def run_script\n" +
				"		\n " +
				"		#{file_code}\n" +
				"		local_variables.each { |localvar|\n " +
				"			 if data_recoveries[localvar.to_sym]\n" +
				"			   devuelve[localvar.to_sym] = eval(localvar)\n" +
				"			 end\n" +
                "            self.automatic_data_recoveries do |code_| eval(code_) end\n" +
				"		}\n" +
				"	end\n" +
				"end\n"

		# run code generated by interpreter
		eval(code)

		# extend generated module
		extend eval(generated_module_name)

		self.devuelve = Hash.new
      $execution_thread=Thread.new do
  
      begin
  		    ######################################################################
	  	    ############                Run script header             ############
		      initialize_run_script
  		    ######################################################################
	  	    ############                   Run script                 ############
		  	  retorno =  run_script()
			    devuelve.merge! retorno if retorno.instance_of? Hash
		
  		rescue Exception => e
        ######################################################################
		    ###########          Running error handling           ############
        Rails.cache.delete WORKER_CACHE_KEY
	  	  error_run_script
		    e.extend PositionErrorHolder
  		  eval_line = e.backtrace.select{ |str| str =~ /^\(eval\)/ }.first
	  	  line_number = eval_line.split(":")[1].to_i - 3
		    piso = line_number - 4
		    piso = piso < 0 ? 0 : piso
  		  lnum = piso
        fragmento = file_code.split("\n")[piso..piso+7]
        if fragmento
  		    e.position_error = fragmento.map{|x| "#{lnum==line_number-1 ? "*" : ""}#{ (lnum+=1) }: #{x}" }.join("\n") + "..."
      	else
            print _("Failure to obtain code fragment: Line number ")+"#{line_number}\n"
            e.position_error = _("Failure to obtain code fragment: Line number ")+"#{line_number}\n"
        end
        # solo en debug mode imprime el error y el stack del error
	  	  print "---> Error: #{e.to_s} <---\n" if debug_mode
		    raise e
  		ensure
        ######################################################################
        ###########                Run script footer             ############
  			finalize_run_script
	  	end
      #thread ends
      end
    $execution_thread.join
		devuelve_aux = Hash.new

		self.devuelve.each do |k,v| devuelve_aux[k.to_s] = v end

        #add arguments to returned data
        self.data.each do |key,value|
          # the returned data have priority over parameters --
          # returned data checker
          unless devuelve_aux.has_key? key.to_s
            devuelve_aux[key.to_s] = value
          end
        end
		return devuelve_aux
	end
    
    #Hash generated with recovery data in every script execution
    def automatic_data_recoveries
		self.data_recoveries.each do |key,code|
			if code
			  unless self.devuelve[key]
			        begin
					   self.devuelve[key] = yield(code)
				    rescue Exception => e
					   raise _("Processing Data Error ")+"'#{key}' (#{code}): #{e.to_s}"
				    end
              end
			end
		end
		devuelve
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
    def stop
       self.execution_flag=1
       self.execution.status=6
       self.execution.save
    end
    
end

