class IndexFix < ActiveRecord::Migration
  def self.up
	remove_index "executions", :case_template_id
	remove_index "executions", :suite_execution_id
  end

  def self.down
	add_index "executions", ["case_template_id"], :name => "index_executions_on_case_template_id"
	add_index "executions", ["suite_execution_id"], :name => "index_executions_on_suite_execution_id"
  end
end

