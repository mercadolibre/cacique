class CreateRoleForProjectManagers < ActiveRecord::Migration
  def self.up
    Project.all.each do |project|
      project.user.has_role "manager", project
    end
  end

  def self.down
    Role.find_all_by_name("manager").each do |role|
      role.destroy
    end
  end
end
