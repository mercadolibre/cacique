class UpdateProjectsWithInactiveManagers < ActiveRecord::Migration
  def self.up
    inactive_users = User.find :all, :conditions => {:active => false}
    admin = User.find_by_login "cacique"
    Project.update_all("user_id=#{admin.id}", "user_id IN (#{inactive_users.collect(&:id).join(',')})")
  end

  def self.down
    # Not rollbackable
  end
end
