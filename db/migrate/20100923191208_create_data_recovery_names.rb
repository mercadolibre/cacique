class CreateDataRecoveryNames < ActiveRecord::Migration
  def self.up
	create_table "data_recovery_names" do |t|
	    t.integer  "circuit_id"
	    t.string   "name"
	    t.string   "code"
	    t.timestamps
  	end
  end

  def self.down
	drop_table :data_recovery_names
  end
end
