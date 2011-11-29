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
    content = content.split(/test_/)[1]
    raise " test_ method not found" if !content
    #if another method is defined after the "test_"
    content.split("def")[0] if content.split("def")
    #Get @selenium lines
    selenium_lines = content.split("\n").select{|line| line.match(/@selenium/)}
    # Get input data from recording
    get_input_data(selenium_lines)
  end

  # GENERATE SCRIPT: The script is generated from the recording
  def generate_script(content,data)
    
    # Header: Get "setup" method to get the url
    content_setup = content.split(/def setup/)[1].split("end")[0]
    header = add_selenium_driver_init(content_setup)
    
    # Body: Get "test_" method
    content_test = content.split(/def test_/)[1]
    content_test.split("def")[0] if content.split("def")
    lines = content_test.split("\n")
    selenium_lines = lines.select{|line| line.match(/@selenium/)}

    # Data: Variable values ​​are replaced by their respective column of the data set
    body = set_data(selenium_lines,data) if !data.empty?
    # @selenium to selenium
    body.gsub!(/    @selenium/, "selenium")

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
        when /.click/
          data = click(line)
        when /.type/
          data = line.split(".type")[1].split(", ")[1]
        when /.select/
          data = nil
        else
          data = nil
      end
      input_data << data.gsub("\\\"", "").gsub("\"", "") if data 
    end
    return input_data
  end

	def click(line)
    line = line.split(".click")[1]
		#is found to be a radiobutton o checkbox,
		#  that meets any of these formats:

		#Not appear the following:
	  sub1   = line  =~ /submit/ 
	  sub2   = line  =~ /Submit/
	  menu   = line  =~ /MENU:/
	  button = line  =~ /Button/	
	  boton  = line  =~ /boton/
	  img    = line 	=~ /\/\/img\[/   
    link   = line  =~ /link/

	  if (!sub1 and !sub2 and !menu and !button and !boton and !img and !link)
	    #In capitals, x ej: NEW o USA
	    up   = line.upcase
	    #returns 0 if equal
	    mayus = ( (line <=> up) == 0)
	    
	    #Format, xej: //input[@id='payMethod' and @name='payMethod' and @value='MS'] 
	    id   = line.match(/\/\/input\[\@id\=\'(\w+)\' and \@name\=\'\w+\' and \@value\=\'\w+\'\]/)

	    #Format, xej: //input[@name='aviso' and @value='PLB']
	    id2 = line.match(/\/\/input\[@name\=\'\w+\' and \@value\=\'\w+\'\]/)
	    
	    #Format, xej: //input[@name='aviso']
	    id3 = line.match(/\/\/input\[@name\=\'\w+\'\]/)	  
	    
	    #Format, xej: auctSN
	    var =  line.match(/((\d*)[a-z](\d*))+((\d*)[A-Z](\d*))+/)
	    
	    #Format, xej: item_zone
	    var1 =  line.match(/((\d*)[a-z](\d*))+_((\d*)[a-z](\d*))+/)
	    
	    #Format, xej: an_calif_id o as_calif_text
	    var2 =  line.match(/((\d*)[a-z](\d*))+_((\d*)[a-z](\d*))+_((\d*)[a-z](\d*))+/)

	    return line if (id or id2 or id3 or var1 or var2 or mayus) 
    end
    return nil
  end	  

  #Get url from content
  def add_selenium_driver_init(content)
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
      values.each{ |value| line.gsub!(/\"#{value}\"/, "data[:#{values_to_reemplace[value]}]")}
    end
    return lines.join("\n")
  end

end
