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

class Parser

  #Parser data 
  def self.parser_data(path)
    content = nil
    File.open( path ) do |file|
			content = file.read
		end
    select_parser(content)
  end

  #Generate script 
  def self.generate_script(data,circuit)
    content = nil
    File.open( "#{RAILS_ROOT}/lib/temp/#{circuit.name}" ) do |file|
			content = file.read
		end
    File.delete( "#{RAILS_ROOT}/lib/temp/#{circuit.name}" )
    select_generator(content,data,circuit)
  end

private

  def self.select_parser(content)
    fields = Array.new
    #Select data collector
    case content
      #WebDriver
      when /require "selenium-webdriver"/
        require "#{RAILS_ROOT}/lib/parsers/web_driver_parser"
      	 data_collector = WebDriverParser.new 
      #Selenium
      when /require "selenium\/client"/
        require "#{RAILS_ROOT}/lib/parsers/selenium_parser"
        data_collector  = SeleniumParser.new
      else
        raise "Parser not found"
    end
    fields  = data_collector.data_collector(content)
    return fields
  end


  def self.select_generator(content,data,circuit)
    #Select script generator
    case content
      #WebDriver
      when /require "selenium-webdriver"/
        require "#{RAILS_ROOT}/lib/parsers/web_driver_parser"
        script_generator = WebDriverParser.new 
      #Selenium
      when  /require "selenium\/client"/
        require "#{RAILS_ROOT}/lib/parsers/selenium_parser"
        script_generator  = SeleniumParser.new
      else
        raise "Parser not found"
    end
    circuit.source_code = script_generator.generate_script(content,data)
    circuit.save
  end


end
