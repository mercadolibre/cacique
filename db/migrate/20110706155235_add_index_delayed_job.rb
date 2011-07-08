class AddIndexDelayedJob < ActiveRecord::Migration
  def self.up
	add_index "delayed_jobs", ["task_program_id"], :name => "index_delayed_jobs_on_task_program_id"
  end

  def self.down
	add_remove "delayed_jobs", "task_program_id"
  end
end
