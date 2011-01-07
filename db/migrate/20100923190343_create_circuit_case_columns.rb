class CreateCircuitCaseColumns < ActiveRecord::Migration
  def self.up
	create_table "circuit_case_columns" do |t|
    		t.string   "name"
    		t.integer  "circuit_id"
    		t.timestamps
  	end
  end

  def self.down
	drop_table :circuit_case_columns
  end
end
