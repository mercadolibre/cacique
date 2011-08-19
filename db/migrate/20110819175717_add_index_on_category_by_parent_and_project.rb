class AddIndexOnCategoryByParentAndProject < ActiveRecord::Migration
  def self.up
    add_index :categories, [:parent_id,:project_id]
  end

  def self.down
  end
end
