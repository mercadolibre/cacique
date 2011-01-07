class CreateExecutionConfigurationValues < ActiveRecord::Migration
  def self.up
	create_table "execution_configuration_values" do |t|
	    t.integer  "suite_execution_id"
	    t.integer  "context_configuration_id"
	    t.string   "value"
	    t.timestamps
 	 end
  end

  def self.down
	drop_table :execution_configuration_values
  end
end
