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

class SeleniumParser
  
  # DATA COLLECTOR: Input data is obtained from "content" that could be variable
  def data_collector(content)
    
    #Get method test_
    content_test = content.split(/def test_\w*\n/)[1]
    raise " test_ method not found" if !content_test
    content_test = content_test.split("def")[0] if content.split("def") 

    #Get @selenium lines
    selenium_lines = content.split("\n").select{|line| line.match(/@selenium/)}

    # Get input data from recording
    get_input_data(selenium_lines)
  end

  # GENERATE SCRIPT: The script is generated from the recording
  def generate_script(content,data)
    
    # Header: Get "setup" method to get the url
    content_setup = content.split(/def setup/)[1].split("end")[0]
    header = add_selenium_init(content_setup)
    
    # Body: Get "test_" method
    content_test = content.split(/def test_/)[1]
    content_test.split("def")[0] if content.split("def")
    lines = content_test.split("\n")
    selenium_lines = lines.select{|line| line.match(/@selenium/) and !line.match(/assert @selenium/) }
    body = selenium_lines.join("\n")

    # Data: Variable values ​​are replaced by their respective column of the data set
    body = set_data(selenium_lines,data) if !data.empty?
    # @selenium to selenium
    body.gsub!(/^(\s)*@selenium/, "selenium")

    #Source code
    source_code = header + body
    source_code

  end

private

  #Selenium sentences are parsed
  def get_input_data(lines)
    input_data = Array.new
    lines.each do |line|
      case line
        when /.type/
          #Ej:  @selenium.type "name=as_first_name", "jaja"
          data = line.split(".type")[1].split(", ")[1]
        when /.select/
          # Ej: @selenium.select "name=as_state", "label=Entre Ríos"
          data = line.split("label=")[1]
        else
          data = nil
      end
      input_data << data.gsub("\\\"", "").gsub("\"", "") if data 
    end
    return input_data
  end

  #Get url from content
  def add_selenium_init(content)
    begin
		  url = content.split(":url => ")[1].split(',')[0].delete "\""
    rescue
      url = "url not found"
    end
		return "selenium_init(\"" + url + "\")\n"
  end		

  # "data" format: {column=> value} 
  # Replaces "data" values for columns in "lines"
  def set_data(lines,data)
    values_to_reemplace = Hash.new
    data.each{|column,value| values_to_reemplace[value] = column } #Format k=>v to v=>k
    values = values_to_reemplace.keys
    lines.each do |line|
      values.each do |value| 
        line.gsub!(/\"#{value}\"/, "data[:#{values_to_reemplace[value]}]")
        line.gsub!(/\"label=#{value}\"/, "\"label=\#\{data[:#{values_to_reemplace[value]}]\}\"" )
      end
    end
    return lines.join("\n")
  end

end
