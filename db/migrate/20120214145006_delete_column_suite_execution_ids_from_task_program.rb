class DeleteColumnSuiteExecutionIdsFromTaskProgram < ActiveRecord::Migration
  def self.up
    remove_column :task_programs, :suite_execution_ids      
  end

  def self.down
     add_column :task_programs, :suite_execution_ids, :text
  end
end
