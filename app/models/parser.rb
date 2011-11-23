require "#{RAILS_ROOT}/lib/generator/processor"

class Parser

  def self.parser_data(path)
    content = nil
    File.open( path ) do |file|
			content = file.read
		end
     select_parser(content)
  end


private

  def self.select_parser(content)
    
    #WebDriver
    if content.match(/require "selenium-webdriver"/)
     require "#{RAILS_ROOT}/lib/parsers/web_driver_parser"
     WebDriverParser.data_collector(content)

    #Selenium
    else
      require "#{RAILS_ROOT}/lib/parsers/selenium_parser"
  	  dc = SeleniumParser.new 
	    processor = Processor.new( dc )
	    processor.process_test_case( content )
	    return dc.data.to_a
    end
  end

end
