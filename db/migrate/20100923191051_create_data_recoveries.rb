class CreateDataRecoveries < ActiveRecord::Migration
  def self.up
	create_table "data_recoveries" do |t|
	    t.integer "execution_id"
	    t.string  "data_name"
	    t.text    "data"
	    t.timestamps
	 end
  end

  def self.down
	drop_table :data_recoveries
  end
end
