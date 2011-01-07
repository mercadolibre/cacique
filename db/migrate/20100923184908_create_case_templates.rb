class CreateCaseTemplates < ActiveRecord::Migration
  def self.up
	create_table "case_templates" do |t|
    		t.integer  "circuit_id"
    		t.integer  "user_id"
    		t.string   "objective"
    		t.string   "priority"
		t.timestamps
  	end
  end

  def self.down
	drop_table :case_templates
  end
end
