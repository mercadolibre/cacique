class AddIndex < ActiveRecord::Migration
  def self.up
	add_index "data_recoveries", ["execution_id"], :name => "index_data_recoveries_on_execution_id"
        add_index "executions", ["id"], :name => "index_executions_on_id"
	add_index "executions", ["case_template_id"], :name => "index_executions_on_case_template_id"
        add_index "case_templates", ["id"], :name => "index_case_templates_on_id"
	add_index "executions", ["suite_execution_id"], :name => "index_executions_on_suite_execution_id"
        add_index "suite_executions", ["id"], :name => "index_suite_executions_on_id"

  end

  def self.down
	remove_index "data_recoveries", :execution_id
        remove_index "executions", :id
	remove_index "executions", :case_template_id
        remove_index "case_templates", :id
	remove_index "executions", :suite_execution_id
        remove_index "suite_executions", :id
  end
end
