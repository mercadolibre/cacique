class AddIndexExecutionSnapshot < ActiveRecord::Migration
  def self.up
	add_index "execution_snapshots", ["execution_id"], :name => "index_execution_snapshots_on_execution_id"
  end

  def self.down
	add_remove "execution_snapshots", "execution_id"
  end
end
