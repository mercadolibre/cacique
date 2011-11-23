class CreateCircuits < ActiveRecord::Migration
  def self.up
	create_table "circuits" do |t|
    		t.text   "name"
    		t.text     "description"
    		t.integer  "category_id"
    		t.text   "source_code"
    		t.integer  "user_id"
		t.timestamps
 	 end
  end

  def self.down
  	drop_table :circuits
  end
end
