class AddColumnExampleInUserFunction < ActiveRecord::Migration
  def self.up
	add_column :user_functions, :example, :text
  end

  def self.down
	remove_column :user_functions, :example
  end
end
