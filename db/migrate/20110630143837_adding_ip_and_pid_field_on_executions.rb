class AddingIpAndPidFieldOnExecutions < ActiveRecord::Migration
  def self.up
     add_column :executions, :ip, :string, :size => 16,:default => "0.0.0.0"
     add_column :executions, :pid, :int, :size => 16,:size => 3
  end

  def self.down
     remove_column :executions, :ip
     remove_column :executions, :pid
  end
end
