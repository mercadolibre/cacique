class FixingUrlParamOnWebdriverInitFunction < ActiveRecord::Migration
  def self.up
  		if function=UserFunction.find_by_name("webdriver_init")
		function.source_code=function.source_code.gsub("def new_object.webdriver_init(iii)","def new_object.webdriver_init(url)")
		function.visibility =true
		function.save
        end
  end

  def self.down
  end
end
