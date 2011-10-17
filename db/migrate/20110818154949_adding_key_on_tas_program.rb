class AddingKeyOnTasProgram < ActiveRecord::Migration
  def self.up
    add_index :task_programs, :project_id
  end

  def self.down
    remove_index :task_programs, :column=>:project_id
  end
end
