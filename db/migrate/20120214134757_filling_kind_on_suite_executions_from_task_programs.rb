class FillingKindOnSuiteExecutionsFromTaskPrograms < ActiveRecord::Migration
  def self.up
    task_programs = TaskProgram.find(:all, :conditions=>["suite_execution_ids != ?", ""])
    task_programs.each do |task_program|
      #Get suite executions of task program
      se_ids = task_program.suite_execution_ids.split(",").collect{|x| x.to_i}
      #Filling kind
      SuiteExecution.update_all("kind=2",[ "id in (?)", se_ids ])
    end
  end

  def self.down
  end
end
