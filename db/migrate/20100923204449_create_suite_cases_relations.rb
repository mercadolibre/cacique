class CreateSuiteCasesRelations < ActiveRecord::Migration
  def self.up
	create_table "suite_cases_relations" do |t|
	    t.integer  "suite_id"
	    t.integer  "case_origin"
	    t.integer  "case_destination"
	    t.integer  "circuit_origin"
	    t.integer  "circuit_destination"
	    t.timestamps
  	end
  end

  def self.down
	drop_table :suite_cases_relations
  end
end
