class AddColumnPublicInUserFunction < ActiveRecord::Migration
  def self.up
      add_column :user_functions, :visibility, :boolean, {:default => false}
  end

  def self.down
      remove_column :user_functions, :visibility
  end
end
