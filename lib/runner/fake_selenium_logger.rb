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
class FakeSeleniumLogger

	def initialize( real_selenium, output )
		@output = output
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
			@output.print "selenium.#{m.to_s}( #{args.map{|x| x.inspect }.join(", ") } )"
			aux = @real_selenium.send(m,*args)
		rescue Exception => e
			@output.print " => Exception: #{e.to_s}\n"
			raise e
		end

        #To not print the entire html into the workling.output
        if m.to_s != "get_html_source"        
		  @output.print " => #{aux.inspect}\n"
		else
		  @output.print " => ... \n"
		end  

		return aux
	end
end
