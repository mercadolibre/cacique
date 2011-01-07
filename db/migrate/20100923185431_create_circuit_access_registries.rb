class CreateCircuitAccessRegistries < ActiveRecord::Migration
  def self.up
	create_table "circuit_access_registries" do |t|
    		t.integer  "circuit_id"
    		t.integer  "user_id"
    		t.string   "ip_address"
    		t.timestamps
  	end
  end

  def self.down
	drop_table :circuit_access_registries
  end
end
