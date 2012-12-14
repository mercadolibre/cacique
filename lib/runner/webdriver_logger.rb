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
class WebdriverLogger

	def initialize( real_webdriver, script_runner )
		@script_runner = script_runner
		@real_webdriver = real_webdriver
	end

	def method_missing(m,*args)
		method_proc(m,*args)
	end

	def method_proc(m, *args)
		begin
			@script_runner.print "webdriver.#{m.to_s}( #{args.map{|x| x.inspect }.join(", ") } )" if @script_runner.debug_mode
			args_ = args.map{|x| @script_runner.evaluate_data(x) }
			aux = @real_webdriver.send(m,*args_)
		rescue Exception => e
			error = e.to_s.split("For documentation")[0]
			@script_runner.print " => Exception: #{error.to_s}\n" if @script_runner.debug_mode
			raise error
		end

        #To not print the entire html into the workling.output
        if @script_runner.debug_mode
	        if m.to_s != "get_html_source"      
			  @script_runner.print " => OK\n"
			else
			  @script_runner.print " => ... \n"
			end  
        end
		return aux
	end
end
