class CreateIndexs < ActiveRecord::Migration
  def self.up
	add_index "case_data", ["case_template_id"], :name => "index_case_data_on_case_template_id"
	add_index "case_templates", ["objective"], :name => "index_case_templates_on_objective"
  	add_index "case_templates", ["priority"], :name => "index_case_templates_on_priority"
 	add_index "case_templates", ["updated_at"], :name => "index_case_templates_on_updated_at"
	add_index "circuit_case_columns", ["circuit_id"], :name => "index_circuit_case_columns_on_circuit_id"
	add_index "executions", ["case_template_id", "user_id"], :name => "index_executions_on_case_template_id_and_user_id"
  	add_index "executions", ["case_template_id"], :name => "index_executions_on_case_template_id"
  	add_index "executions", ["suite_execution_id"], :name => "index_executions_on_suite_execution_id"
  	add_index "executions", ["updated_at"], :name => "index_executions_on_updated_at"
  	add_index "executions", ["user_id"], :name => "index_executions_on_user_id"
	add_index "suite_executions", ["suite_id"], :name => "index_suite_executions_on_suite_id"
	add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
	add_index "versions", ["number"], :name => "index_versions_on_number"
  	add_index "versions", ["versioned_type", "versioned_id"], :name => "index_versions_on_versioned_type_and_versioned_id"
  end

  def self.down
  end
end
