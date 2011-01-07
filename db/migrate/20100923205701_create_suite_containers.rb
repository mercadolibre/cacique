class CreateSuiteContainers < ActiveRecord::Migration
  def self.up
	create_table "suite_containers" do |t|
	    t.integer  "times"
	    t.integer  "suite_id"
	    t.timestamps
  	end
  end

  def self.down
	drop_table :suite_containers
  end
end
