class CreateCaseData < ActiveRecord::Migration
  def self.up
	create_table "case_data" do |t|
    		t.integer  "circuit_case_column_id"
    		t.integer  "case_template_id"
    		t.text     "data"
		t.timestamps
  	end
  end

  def self.down
	drop_table :case_data
  end
end
