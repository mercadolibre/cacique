class ApiKeysController < ApplicationController


before_filter :login_from_cookie
before_filter :login_required
  
# Create or re-generate the API key
def create
  u=current_user.id
  Rails.cache.delete("user_#{current_user.id}")
  us=User.find(u)
  us.enable_api!
             
  respond_to do |format|
    format.html { redirect_to edit_user_path(current_user) }
  end
end
                              
# Delete the API key
def destroy
  current_user.disable_api!
                                       
  respond_to do |format|
    format.html { redirect_to edit_user_path(current_user) }
  end
end
end
