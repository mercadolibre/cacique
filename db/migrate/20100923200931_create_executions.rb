class CreateExecutions < ActiveRecord::Migration
  def self.up
	create_table "executions" do |t|
	    t.integer  "circuit_id"
	    t.integer  "time_spent",         :default => 0 
	    t.integer  "user_id"
	    t.integer  "case_template_id"
	    t.integer  "suite_execution_id"
	    t.integer  "status",             :default => 0
	    t.text     "error"
	    t.text     "position_error"
	    t.string   "worker_pid"
	    t.text     "output"
	    t.timestamps
  	end
  end

  def self.down
	drop_table :executions
  end
end
