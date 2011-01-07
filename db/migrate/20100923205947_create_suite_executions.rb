class CreateSuiteExecutions < ActiveRecord::Migration
  def self.up
	create_table "suite_executions" do |t|
	    t.integer  "suite_id"
	    t.integer  "user_id"
	    t.integer  "suite_container_id"
	    t.string   "identifier",         :limit => 50, :default => " "
	    t.integer  "project_id"
	    t.integer  "time_spent",         :default => 0 
	    t.integer  "status",             :default => 0
	    t.timestamps
  	end
  end

  def self.down
	drop_table :suite_executions
  end
end
