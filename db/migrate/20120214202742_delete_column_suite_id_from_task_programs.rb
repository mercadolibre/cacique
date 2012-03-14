class DeleteColumnSuiteIdFromTaskPrograms < ActiveRecord::Migration
  def self.up
    remove_column :task_programs, :suite_id
  end

  def self.down
    add_column :task_programs, :suite_id, :integer
  end
end
