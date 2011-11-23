class CreateSuites < ActiveRecord::Migration
  def self.up
	create_table "suites" do |t|
	    t.string   "name"
	    t.text     "description"
	    t.integer  "project_id"
	    t.timestamps
  	end
  end

  def self.down
	drop_table :suites
  end
end
