class AddIndexSuiteExecutionsKind < ActiveRecord::Migration
  def self.up
    add_index "suite_executions", ["kind"], :name => "index_suite_executions_on_kind"    
  end

  def self.down
    remove_index "suite_executions", "kind"    
  end
end
