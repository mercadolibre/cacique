module UsersHelper
  def user_list users
    users.sort.collect {|u| [ truncate(u.login, :ommision => "...", :length => 60), u.id ] }
  end
end