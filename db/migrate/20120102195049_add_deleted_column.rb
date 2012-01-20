class AddDeletedToSuite < ActiveRecord::Migration
  def self.up
    add_column :suites, :deleted, :boolean, { :default => false }
    add_column :circuits, :deleted, :boolean, { :default => false }
    add_column :case_templates, :deleted, :boolean, { :default => false }
  end

  def self.down
    remove_column :suites, :deleted
    remove_column :circuits, :deleted
    remove_column :case_templates, :deleted
  end
end
