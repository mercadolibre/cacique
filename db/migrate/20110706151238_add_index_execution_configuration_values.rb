class AddIndexExecutionConfigurationValues < ActiveRecord::Migration
  def self.up
	add_index "execution_configuration_values", ["suite_execution_id"], :name => "index_execution_configuration_values_on_suite_execution_id"
	add_index "execution_configuration_values", ["context_configuration_id"], :name => "index_execution_configuration_values_on_context_configuration_id"
  end

  def self.down
	remove_index "execution_configuration_values", "suite_execution_id"
	remove_index "execution_configuration_values", "context_configuration_id"
  end
end
