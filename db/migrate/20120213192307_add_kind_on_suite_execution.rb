class AddKindOnSuiteExecution < ActiveRecord::Migration
  def self.up
      add_column :suite_executions, :kind, :integer, {:default => 0, :limit => 8}
  end

  def self.down
      remove_column :suite_executions, :kind
  end
end
