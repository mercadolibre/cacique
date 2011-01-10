class AddColumnProgamIdinDelayedJob < ActiveRecord::Migration
  def self.up
	add_column :delayed_jobs, :status, :tinyint, :default => 1
	remove_column :delayed_jobs, :suite_id
  end

  def self.down
  	remove_column :delayed_jobs, :status
	add_column :delayed_jobs, :suite_id, :integer
  end
end
