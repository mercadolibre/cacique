class CreateExecutionSnapshots < ActiveRecord::Migration
  def self.up
	create_table "execution_snapshots" do |t|
	    t.integer  "execution_id"
	    t.string   "name"
	    t.text   "content"
	    t.timestamps
  	end
  end

  def self.down
	drop_table :execution_snapshots
  end
end
