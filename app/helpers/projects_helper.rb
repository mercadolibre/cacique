module ProjectsHelper
  def manager_candidates project
    project.users.select{|u| u.active?}.collect {|u| [ u.login, u.id ]}
  end
end
