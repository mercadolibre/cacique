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
require "rubygems"
require "lib/generator/fake_selenium"
require "lib/generator/processor"
require "lib/generator/selenium_data_collector"
require "lib/generator/selenium_generate_circuit"

class CircuitGenerator
	def self.generate( hashparam )
		input_file = hashparam[:input_file]
		raise "no output given" unless input_file
		output_file = hashparam[:output_file]
		raise "no input given" unless output_file
		
		replacement_info = hashparam[:replacement_info] || {}
		
		return SeleniumGenerateCircuit.generate(output_file) do |dc|		
			dc.subs_data.add_selenium_driver_init(input_file)
			dc.subs_data.subs_hash = replacement_info
			processor = Processor.new( dc )
			processor.process_test_case(input_file)
		end		
	end
end
