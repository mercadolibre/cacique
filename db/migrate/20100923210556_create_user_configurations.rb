class CreateUserConfigurations < ActiveRecord::Migration
  def self.up
	create_table "user_configurations" do |t|
	    t.integer "user_id"
	    t.boolean "send_mail", :default=>true
	    t.boolean "debug_mode"
	    t.string  "remote_control_mode"
	    t.string  "remote_control_addr"
	    t.string  "remote_control_port"
	    t.timestamps
  	end
  end

  def self.down
	drop_table :user_configurations
  end
end
