class RefactoringSeleniumFunction < ActiveRecord::Migration
  def self.up
	if function=UserFunction.find_by_name("selenium")
		function.description = "Returns the open controller of selenium."
		function.source_code = "def new_object.selenium();raise \"selenium_init not called or was called incorrectly\" unless @selenium\nSeleniumLogger.new(@selenium,self)\n \n \n end;"
		function.save
     end

  end

  def self.down
  end
end
