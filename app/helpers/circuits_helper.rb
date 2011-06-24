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
module CircuitsHelper
  
  def cambiarSignos(input) 
     input = input.gsub("---","[")
     input = input.gsub("-.-","]")
     input = input.gsub("**","=")
    return input
  end
  
  def valueForView(input)
    text  = Array.new
    text_view = Array.new

  #verify if comply with any of these formats:
    
    #Format, xej: //input[@id='payMethod' and @name='payMethod' and @value='MS'] 
    id   = input.match(/\/\/input\[\@id\=\'\w+\' and \@name\=\'\w+\' and \@value\=\'\w+\'\]/)
    
    #Format, xej: //input[@name='aviso' and @value='PLB']
    id2 = input.match(/\/\/input\[@name\=\'\w+\' and \@value\=\'\w+\'\]/)
    
    #Format, xej: //input[@name='aviso']
    id3 = input.match(/\/\/input\[@name\=\'\w+\'\]/)    

    if (  !id.nil? or !id2.nil? or !id3.nil?  )
      if ( !id. nil? or !id2.nil? )
        text = input.split("@value='")[1].split("']")[0]
      elsif !id3.nil?
        text = input.split("@name='")[1].split("']")[0]
      end
      text_view = text
    else         
      text_view = input
    end
    return text_view
  end
  
end
