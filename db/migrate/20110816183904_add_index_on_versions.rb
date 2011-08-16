class AddIndexOnVersions < ActiveRecord::Migration
  def self.up
     add_index(:versions, [:versioned_type, :versioned_id])
  end

  def self.down
     remove_index(:versions, :column => [:versioned_type, :versioned_id])
  end
end
