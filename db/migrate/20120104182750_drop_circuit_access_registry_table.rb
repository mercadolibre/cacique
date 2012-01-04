class DropCircuitAccessRegistryTable < ActiveRecord::Migration
  def self.up
    drop_table :circuit_access_registries
  end

  def self.down
    create_table "circuit_access_registries" do |t|
      t.integer  "circuit_id"
      t.integer  "user_id"
      t.string   "ip_address"
      t.timestamps
    end
  end
end
