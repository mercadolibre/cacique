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
class SeleniumDataCollector
	
	attr_accessor	:data
	
	class Comodin
		def method_missing(m,*x)
			Comodin.new
		end
	end	

	@@comodin = Comodin.new
	
	
	class Data

		class SeleniumAction
			attr_accessor	:obj_type
			attr_accessor	:args
			attr_accessor	:id
			
			def [] (index)
				self.args[index]
			end
			
			def initialize( obj_type_arg, args_arg )
				@obj_type = obj_type_arg
				@args = args_arg
				self.id = self.args[0]
			end
			
		end

		attr_accessor	:selenium_actions
		attr_accessor	:has_item_id
		
		def initialize
			@selenium_actions = Array.new
			@has_item_id = nil
			@element_sequence_id = 1
		end
		
		def to_a
			if @has_item_id
				return @selenium_actions + [SeleniumAction.new("type", [@has_item_id, @has_item_id] )]
			else
				return @selenium_actions
			end
		end
		
		def to_hash
			h = Hash.new
			
			self.each_type do |key,value|
				h[key] = value
			end
			
			return h
		end
		
		def add_selenium_action( act, *args )
			@selenium_actions = @selenium_actions + [ SeleniumAction.new(act,args.map{|x| "#{@element_sequence_id }:#{x}"} ) ]
			@element_sequence_id = @element_sequence_id + 1
		end
		
		def add_open(uri)
			add_selenium_action("open",uri)
		end
		
		def add_type( input, text )
			add_selenium_action("type",input,text)
		end
		
		def add_click( click_spec )
			add_selenium_action("click",click_spec)
		end
		
		def add_checkbox( check_id )
			add_selenium_action("checkbox", check_id, check_id)
		end
		
		def open(uri)
			add_selenium_action( "open", uri)
		end

	end
	
	def initialize
		@data = Data.new
	end
	
	def method_missing( m, *x )
		# method missing no debe hacer nada
		@@comodin
	end
	
	def open(uri)
		self.data.open(uri)
	end

	def type(input,text)
		self.data.add_type(input,text)
	end
	
	def select(input,label)
		self.data.add_type(input, label)
	end
	
	def click(input)
		#is found to be a radiobutton o checkbox,
		#  that meets any of these formats:

		#Not appear the following:
	  sub1   = input  =~ /submit/ 
	  sub2   = input  =~ /Submit/
	  menu   = input  =~ /MENU:/
	  button = input  =~ /Button/	
	  boton  = input  =~ /boton/
	  img    = input 	=~ /\/\/img\[/   
    link   = input  =~ /link/
	  
	  #In capitals, x ej: NEW o USA
	  up   = input.upcase
	  #returns 0 if equal
	  mayus = input <=> up
	  
	  #Format, xej: //input[@id='payMethod' and @name='payMethod' and @value='MS'] 
	  id   = input.match(/\/\/input\[\@id\=\'(\w+)\' and \@name\=\'\w+\' and \@value\=\'\w+\'\]/)
	  
	  #Format, xej: //input[@name='aviso' and @value='PLB']
	  id2 = input.match(/\/\/input\[@name\=\'\w+\' and \@value\=\'\w+\'\]/)
	  
	  #Format, xej: //input[@name='aviso']
	  id3 = input.match(/\/\/input\[@name\=\'\w+\'\]/)	  
	  
	  #Format, xej: auctSN
	  var =  input.match(/((\d*)[a-z](\d*))+((\d*)[A-Z](\d*))+/)
	  
	  #Format, xej: item_zone
	  var1 =  input.match(/((\d*)[a-z](\d*))+_((\d*)[a-z](\d*))+/)
	  
	  #Format, xej: an_calif_id o as_calif_text
	  var2 =  input.match(/((\d*)[a-z](\d*))+_((\d*)[a-z](\d*))+_((\d*)[a-z](\d*))+/)

	  if id
		  self.data.add_checkbox( id[1] )
	   else
		   self.data.add_checkbox( input )
	  end
 end	  

end
