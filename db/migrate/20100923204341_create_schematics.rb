class CreateSchematics < ActiveRecord::Migration
  def self.up
	create_table "schematics" do |t|
	    t.integer  "suite_id"
	    t.integer  "circuit_id"
	    t.integer  "position"
	    t.integer  "case_template_id"
	    t.timestamps
  	end
  end

  def self.down
	drop_table :schematics
  end
end
