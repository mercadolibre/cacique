class AddingApiKeyOnUsers < ActiveRecord::Migration
  def self.up
     User.find_all_by_api_key("").each do |usr|
        usr.enable_api!
     end
  end

  def self.down
	
  end
end
