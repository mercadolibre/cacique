class CreateContextConfigurations < ActiveRecord::Migration
  def self.up
	create_table "context_configurations" do |t|
	    t.string   "name"
	    t.string   "view_type"
	    t.text     "values"
	    t.boolean  "field_default", :default => false
	    t.boolean  "enable", :default => true
	    t.timestamps
	 end
  end

  def self.down
	drop_table :context_configurations
  end
end
