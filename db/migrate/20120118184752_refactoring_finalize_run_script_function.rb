class RefactoringFinalizeRunScriptFunction < ActiveRecord::Migration
  def self.up
	if function=UserFunction.find_by_name("finalize_run_script")
		function.description = "This function will be run ALWAYS after a script"
		function.source_code = function.source_code.gsub(/end;$/, "# Stop the execution of Selenium\nselenium_stop\n# Stop the execution of Webdriver\nwebdriver_stop\n end;")
		function.save
     end
  end

  def self.down
  end
end
