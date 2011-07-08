class RemovingWorkerPid < ActiveRecord::Migration
  def self.up
     remove_column :executions, :worker_pid
  end

  def self.down
     add_column :executions, :worker_pid, :string
  end
end
