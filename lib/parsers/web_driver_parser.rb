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

class WebDriverParser
 
  
  # DATA COLLECTOR: Input data is obtained from "content" that could be variable
  def data_collector(content)
    #Get method test_
    content = content.split(/test_/)[1]
    raise " test_ method not found" if !content
    #if another method is defined after the "test_"
    content.split("def")[0] if content.split("def")
    #Get @driver lines
    driver_lines = content.split("\n").select{|line| line.match(/@driver/)}
    # Get input data from recording
    get_input_data(driver_lines)
  end

  # GENERATE SCRIPT: The script is generated from the recording
  def generate_script(content,data)
    
    # Get method test_
    content_test = content.split(/def test_\w*\n/)[1]
    raise " test_ method not found" if !content_test
    content_test = content_test.split("def")[0] if content.split("def") 

    # Change [driver.get "url"] for [web_driver_init "url"]
    content_test.gsub!(/(\s)*@driver.get/, "webdriver_init")

    # Get @driver lines without asserts
    lines = content_test.split("\n")
    driver_lines = lines.select{|line| line.match(/@driver|webdriver_init/) and !line.match(/assert_equal/)}
    source_code = driver_lines.join("\n")

    # Data: Variable values ​​are replaced by their respective column of the data set
    source_code = set_data(driver_lines,data) if !data.empty?
    # Delete spaces before @driver
    source_code.gsub!(/^(\s)*@driver/, "@driver")

    # Source code
    source_code

  end

private

  #Web driver sentences are parsed
  def get_input_data(lines)
    input_data = Array.new
    lines.each do |line|
      case line
        when /.send_keys/
          data = line.split("send_keys ")[1]
        else
          data = nil
      end
      input_data << data.gsub("\\\"", "").gsub("\"", "") if data 
    end
    return input_data
  end

  # "data" format: {column=> value} 
  # Replaces "data" values for columns in "lines"
  def set_data(lines,data)
    values_to_reemplace = Hash.new
    data.each{|column,value| values_to_reemplace[value] = column } #Format k=>v to v=>k
    values = values_to_reemplace.keys
    lines.each do |line|
      values.each{ |value| line.gsub!(/\"#{value}\"/, "data[:#{values_to_reemplace[value]}]")}
    end
    return lines.join("\n")
  end

end
