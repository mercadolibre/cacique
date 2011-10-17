class AddIndexForCircuits < ActiveRecord::Migration
  def self.up
     add_index(:circuits, :category_id)
  end

  def self.down
     remove_index :accounts, :column => :category_id
  end
end
