class CreateUserFunctions < ActiveRecord::Migration
  def self.up
	create_table "user_functions" do |t|
	    t.integer  "user_id"
	    t.integer  "project_id"
	    t.string   "name", :limit => 50
	    t.text     "description"
	    t.integer  "cant_args",   :default => 0
	    t.text     "source_code"
    	    t.timestamps
  	end
  end

  def self.down
	drop_table :user_functions
  end
end
