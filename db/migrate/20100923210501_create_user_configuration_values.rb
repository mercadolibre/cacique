class CreateUserConfigurationValues < ActiveRecord::Migration
  def self.up
	create_table "user_configuration_values" do |t|
	    t.integer  "user_configuration_id"
	    t.integer  "context_configuration_id"
	    t.string   "value",                    :default => ""
	    t.timestamps
  	end
  end

  def self.down
	drop_table :user_configuration_values
  end
end
