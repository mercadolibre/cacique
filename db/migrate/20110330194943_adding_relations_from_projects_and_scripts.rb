class AddingRelationsFromProjectsAndScripts < ActiveRecord::Migration
  def self.up
    add_column :circuits, :project_id, :int
  end

  def self.down
    remove_column :circuits, :project_id
  end
end
