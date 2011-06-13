class CreateVersions < ActiveRecord::Migration
  def self.up
	create_table "versions" do |t|
	    t.integer  "versioned_id"
	    t.string   "versioned_type"
	    t.text     "changes"
	    t.integer  "number"
	    t.datetime "created_at"
	    t.string   "message",        :default => ""
	    t.integer  "user_id"
	    t.timestamps
  	end
  end

  def self.down
	drop_table :versions
  end
end
