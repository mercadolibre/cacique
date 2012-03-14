class AddColumnExecutionParamsInTaskProgram < ActiveRecord::Migration
  def self.up
	add_column :task_programs, :execution_params, :text
  end

  def self.down
	remove_column :task_programs, :execution_params
  end
end
