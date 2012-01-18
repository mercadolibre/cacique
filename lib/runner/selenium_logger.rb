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
class SeleniumLogger

	class Inner
		def self.process_url_bot_y(url)
			b = url.split("?")
			new_url = ""
			if b.size == 2 then
				parameters = b[1]
				uri = b[0]
				array = parameters.split("&")
				new_url = uri + "?" + array.select{ |x| x != "_PA" }.join("&") + "&bot=Y" + ( array.include?("_PA") ? "&_PA":"" )
			else
				uri = b[0]
				new_url = uri + "?bot=Y"
			end
			print "converting url #{url} to #{new_url}\n"
			return new_url
		end
	end

	def initialize( real_selenium, script_runner )
		@script_runner = script_runner
		@real_selenium = real_selenium
	end

	def open(*args)
		method_proc("open",*args)
	end

	def type(*args)
		method_proc("type",*args)
	end

	def select(*args)
		method_proc("select",*args)
	end

	def method_missing(m,*args)
		method_proc(m,*args)
	end

	def method_proc(m, *args)

		begin
			@script_runner.print "selenium.#{m.to_s}( #{args.map{|x| x.inspect }.join(", ") } )" if @script_runner.debug_mode
			args_ = args.map{|x| @script_runner.evaluate_data(x) }
			aux = @real_selenium.send(m,*args_)
		rescue Exception => e
			@script_runner.print " => Exception: #{e.to_s}\n" if @script_runner.debug_mode
			raise e
		end

        if @script_runner.debug_mode
	        #To not print the entire html into the workling.output
	        if m.to_s != "get_html_source"        
			  @script_runner.print " => #{aux.inspect}\n"
			else
			  @script_runner.print " => ... \n"
			end  
        end

		return aux
	end
end
