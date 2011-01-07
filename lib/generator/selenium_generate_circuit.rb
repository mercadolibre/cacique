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
require "#{RAILS_ROOT}/lib/generator/processor.rb"

class SeleniumGenerateCircuit

	attr_reader	:generator
	attr_reader	:subs_data
	
	class MethodBuilderObject
		
		def initialize( str = nil )
			@str = str
		end
		
		def method_missing(m,*x)
			args = x.map{|a| "#{a.to_ruby_expr}"}.join(",")
			
			unless m.to_s == "[]"
				method_call = "#{m}(#{args})"
			else
				return MethodBuilderObject.new( "#{@str}[#{args}]")
			end
			
			if @str
				MethodBuilderObject.new( "#{@str}.#{method_call}")
			else
				MethodBuilderObject.new( method_call)
			end
		end
		
		def to_ruby_expr
			@str
		end
	end	
	
	
	def self.generate_circuit( path_name )
		SeleniumGenerateCircuit.generate() do |dc|
			dc.subs_data.add_selenium_driver_init( path_name )
			dc.subs_data.subs_hash = {}
			processor = Processor.new( dc )
			processor.process_test_case( path_name )
		end
		
	end

	def self.generate(*x)
		sgc = SeleniumGenerateCircuit.new(*x)
		begin
			sgc.generator.init_circuit
			yield(sgc)
		ensure
			sgc.generator.end_circuit
		end
		
		return sgc.generator.script_text
	end

	def initialize()
		@generator = InnerClass.new()
		@subs_data = @generator
	end
	
	class InnerClass
		
		attr_accessor	:subs_hash
		attr_accessor	:script_text
		
		def add_type_subs( hash )
			hash.each do |k,v|
				@subs_hash[k] = v
				
				text = k.split(":")[1..-1].join(":") 
				
				@reduced_subs_hash[text] = true
			end
		end
		
		def subs_hash= (arg)
			@subs_hash = arg
			
			arg.each do |k,v|
				text = k.split(":")[1..-1].join(":") 
				@reduced_subs_hash[text] = true
			end
		end
		
		def format_text( text, m_ = "" )
			if @reduced_subs_hash[text]			
				complete_index = "#{@element_sequence_id}:#{text}"

				if @subs_hash.select{|x,y| x == complete_index}.size > 0
					
					@element_sequence_id = @element_sequence_id + 1

					if @subs_hash[complete_index].to_s.size > 0
						if text.match(/^label=/)
							return "\"label=\#\{data[:#{@subs_hash[complete_index]}]\}\""
						elsif text.match(/\/\/input\[/)
							
							begin
								name = text.match(/\@name\=\'(\w+\_?\-?)+\'/)[1]
								id = text.match(/\@id\=\'(\w+\_?\-?)+\'/)[1]
								return "\"//input[@id='#{id}' and @name='#{name}' and @value='\#\{data\[\:#{@subs_hash[complete_index]}\]\}']\""
							rescue 
								return "data[:#{@subs_hash[complete_index]}]"
							end
						else
							return "data[:#{@subs_hash[complete_index]}]"
						end

					else
						return text.to_ruby_expr
					end
				else
					return text.to_ruby_expr
				end
			else
				text.to_ruby_expr
			end
		end
		
		def add_selenium_driver_init(path)
				
			url = "No se encontro url"
			
			File.open(path) do |file|
				file.each_line do |line|
					if line.match(/Selenium::SeleniumDriver.new/)
						url = line.match(/http(s?)\:\/\/(\w+\=?\.?\_?\/?\??\&?)*/)[0]
				  elsif line.match(/:url => /)
            url = line.split('=> ')[1].split(',')[0].delete "\""
					end
				end
			end
			
			@script_text << "selenium_init(\"" + url + "\")\n"				
			
		end		

		def initialize()
			
			@script_text = String.new
			@subs_hash = Hash.new
			@reduced_subs_hash = Hash.new
			
			@element_sequence_id = 2
		end
		
		def init_circuit 
		end
		
		def end_circuit
			self.proc_method_missing("m","x")
		end

		def define_class_name(name_file)
			name_file.gsub!(".rb","")
			aux = name_file.split("_")
			d = String.new
			aux.each do |w|
				d = d + w.to_s.capitalize
		    end
			d
		end	
		
		def puts(*x)
			x.each{|elem| @script_text << elem}
		end
		
		def self.iterator_function(count,m_,args)
			if m_.to_s == "is_element_present"
				"wait_for_element_present #{args[0]}, #{count+1} "
			else
				"#{count+1}.times{ break if (selenium.#{m_}(#{args}) rescue false); sleep 1 }"
			end
		end
		
		def proc_method_missing(m,*x_original)
			
			x = nil
			
			if @last_call
				if @last_call == [m,x_original]
					@count = @count.to_i + 1
				else
					x_ = @last_call[1]
					m_ = @last_call[0]	
					
					if @count.to_i > 0
						if m_.to_s =~ /is_/
							if m_.to_s == "open"
								x = "\"" + x_ + "\""
							else
								x = x_.map{ |text| self.format_text(text) }
							end
							args = x.join(",")
							# "#{@count+1}.times{ break if (selenium.#{m_}(#{args}) rescue false); sleep 1 }"
							self.puts InnerClass.iterator_function(@count,m_,x), "\n"
						else
							(0..@count).each do |qqq|
								self.process_single_last_call
							end
						end
					else
						self.process_single_last_call
					end
					
					@count = 0
				end
			end			
			@last_call = [m,x_original]
		end
		
		def process_single_last_call
			x_ = @last_call[1]
			m_ = @last_call[0]
			
			if m_.to_s == "open"
				args = x_.map{|a| "\"" + a + "\""}
			else
				args = x_.map{ |text| self.format_text(text, m_) }.join(",")
			end
			
			if m_ == :click
				id   = x_[0].match(/\/\/input\[\@id\=\'(\w+)\' and \@name\=\'\w+\' and \@value\=\'\w+\'\]/)

				click_code = nil
				if id
					click_code = id[1]
				else
					click_code = x_[0]
				end	
			else
				self.puts "selenium.#{m_} #{args}\n"
			end
		end
	end

	def method_missing( m, *x )
		
		unless m.to_s =~ /^get_/
			self.generator.proc_method_missing(m, *x)
		end
		
		args = x.map{|a| "#{a.to_ruby_expr}"}.join(",")
		
		if m.to_s =~ /^is_/
			return false
		else
			return MethodBuilderObject.new("selenium.#{m}(#{args})")
		end
	end
	
	def open(p)
		self.generator.proc_method_missing("open", p )
	end

	def type(input,text)
		self.generator.proc_method_missing("type",input,text)	
	end

	def select(input,text)
		self.generator.proc_method_missing("select",input,text)
	end

	def click(click_code)		
			self.generator.proc_method_missing("click", click_code)
  end
	
end


class Object
	def to_ruby_expr
		"\"#{self.to_s.gsub("\\","\\\\\\\\").gsub("\"","\\\"").gsub("\#","\\\#") }\""
	end
end

class Fixnum
	def to_ruby_expr
		"#{self}"
	end
end

