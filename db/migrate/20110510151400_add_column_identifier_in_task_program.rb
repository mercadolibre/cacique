class AddColumnIdentifierInTaskProgram < ActiveRecord::Migration
  def self.up
	 add_column :task_programs, :identifier, :string, {:limit => 50, :default => " "}  
  end

  def self.down
	remove_column :task_programs, :identifier
  end
end
