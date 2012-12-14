class AddNativeParamsCloumnUserFunctions < ActiveRecord::Migration
  def self.up
      add_column :user_functions, :native_params, :boolean, {:default => false}
  end

  def self.down
      remove_column :user_functions, :native_params
  end
end
