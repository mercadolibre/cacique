class CreateUsers < ActiveRecord::Migration
  def self.up
	create_table "users" do |t|
	    t.string   "login"
	    t.string   "name"
	    t.string   "email"
	    t.string   "crypted_password",          :limit => 40
	    t.string   "salt",                      :limit => 40
	    t.string   "remember_token"
	    t.datetime "remember_token_expires_at"
	    t.boolean  "active",                    :default => true
	    t.string   "language", 		    :limit => 5, :default =>"en_US"
	    t.timestamps
  	end
  end

  def self.down
	drop_table :users
  end
end
