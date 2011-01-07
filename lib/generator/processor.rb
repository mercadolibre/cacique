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
require "#{RAILS_ROOT}/lib/generator/fake_selenium"

class Processor
	attr_accessor	:data_collector
	
	def initialize( dc = nil)
		@data_collector = dc
	end
	
	def process_test_case( path )
		# instantiate a data collector
		FakeSelenium::SeleniumDriver.init_callback =
			proc do |x|
				x.call_obj = @data_collector
			end
		
		# process the script requires defining the fake (test/unit y selenium)
		content = nil
		File.open( path ) do |file|
			content = file.read
		end
		
		generated_class_name = "GeneratedClassName_#{rand(1000000000)}"
		content_fake = "require \"lib/generator/fake_selenium\"\nrequire \"lib/generator/fake_test_unit\"\n\nclass #{generated_class_name} < Test::Unit::FakeTestCase \n" + content.split("\n")[4..-1].select{|line| not line =~ /class / }.join("\n")+"\n"
		# load the modified script
		eval(content_fake)


		# engage the times of Fixnum
		test = eval(generated_class_name).new
		test.instance_eval do
			@selenium  = FakeSelenium::SeleniumDriver.new
		
		end
	
		# find a method that begins with the character sequence  "test_"
		metodos = test.methods.select { |m| m =~ /^test_/ }
		
		if metodos.size > 1 
			raise "Imposible procesar el testcase: hay mas de un metodo test_*: #{metodos.join(",") }"
		elsif metodos.size == 0 
			raise "Imposible procesar el testcase: No hay metodos que empiezen con test_"
		else
			el_metodo_test = metodos.first
			test.send(el_metodo_test)
		end
	end
	
	
end
