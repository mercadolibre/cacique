class UpdateProjectsWithInactiveManagers < ActiveRecord::Migration
  def self.up
    inactive_users = User.find :all, :conditions => {:active => false}
    admin = User.find_by_login "cacique"
    unless admin
      begin
        root = Role.find_by_name "root"
        admin = RolesUser.find_by_role_id!(root.id).user
      rescue
        raise "'root' not found"
      end
    end
    Project.update_all("user_id=#{admin.id}", "user_id IN (#{inactive_users.collect(&:id).join(',')})") unless inactive_users
  end

  def self.down
    # Not rollbackable
  end
end
