class AddColumnPublicInUserFunction < ActiveRecord::Migration
  def self.up
      add_column :user_functions, :public, :boolean, {:default => false}
  end

  def self.down
      remove_column :user_functions, :public
  end
end
