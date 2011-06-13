class CreateSuiteFieldsRelations < ActiveRecord::Migration
  def self.up
	create_table "suite_fields_relations" do |t|
	    t.integer  "suite_id"
	    t.integer  "circuit_origin_id"
	    t.integer  "circuit_destination_id"
	    t.string   "field_origin"
	    t.string   "field_destination"
	    t.timestamps
  	end
  end

  def self.down
	drop_table :suite_fields_relations
  end
end
