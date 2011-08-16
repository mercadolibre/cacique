class AddingCategoryIndexForCategoryParentId < ActiveRecord::Migration
  def self.up
     add_index :categories, :parent_id
  end

  def self.down
     remove_index :categories, :column=> :parent_id
  end
end
