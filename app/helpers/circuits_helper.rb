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
