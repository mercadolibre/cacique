class DeactiveUsersOnCreate < ActiveRecord::Migration
  def self.up
    change_column :users, :active, :bool,:default => false, :null => false
  end

  def self.down
     change_column :users, :active,:bool ,:default => true, :null => false
  end
end
