class AddingIndexOnExecutionUpdatedAtUserId < ActiveRecord::Migration
  def self.up
     add_index :executions, [:case_template_id,:user_id]
  end

  def self.down
     remove_index :executions,:index_executions_on_case_template_id_and_user_id
  end
end
