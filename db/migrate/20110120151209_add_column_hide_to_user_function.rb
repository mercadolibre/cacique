class AddColumnHideToUserFunction < ActiveRecord::Migration
  def self.up
	add_column :user_functions, :hide, :boolean, {:default => false}
  end

  def self.down
	remove_column :user_functions, :hide
  end
end
