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
require "#{RAILS_ROOT}/lib/parsers/web_driver_parser"
require "#{RAILS_ROOT}/lib/parsers/selenium_parser"

class Parser
  #Parsers available
  @parsers = { WebDriverParser => 'require "selenium-webdriver"',
               SeleniumParser  => 'require "selenium/client"'}

  #Parser data 
  def self.parser_data(path)
    #Get file content
    content = self.get_file_content(path)
    #Syntax check
    syntax = Circuit.syntax_checker(content)
    errors = syntax[:errors].select{|line| !line.match(/class\/module name/)}#Selenium class name error 
    raise errors.join("\n") if !errors.empty?
    #Get parser
    parser = select_parser(content)
    #Get variable data
    return  parser.data_collector(content)

  end

  #Generate script 
  def self.generate_script(data,circuit)
    #Get file content
    content = self.get_file_content("#{RAILS_ROOT}/lib/temp/#{circuit.name}")
    File.delete( "#{RAILS_ROOT}/lib/temp/#{circuit.name}" )
    #Get parser
    parser = select_parser(content)
    #Generate script
    circuit.source_code = parser.generate_script(content,data)
    circuit.save
  end

private

  def self.select_parser(content)
    #Select parser
    parser = @parsers.select{ |k, regex| content.include?(regex) }.first
    raise "Parser not found" if parser.empty?
    #Intance parser
    parser.first.new
  end

  def self.get_file_content(path)
    content = nil
    File.open(path) do |file|
			content = file.read
		end
    content
  end

end
