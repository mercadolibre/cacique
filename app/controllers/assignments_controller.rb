 #
 #  @Authors:    
 #      Guerra Brenda                   brenda.guerra.7@gmail.com
 #      Crosa Fernando                  fernandocrosa@hotmail.com
 #      Branciforte Horacio             horaciob@gmail.com
 #      Luna Juan                       juancluna@gmail.com
 #      
 #  @copyright (C) 2010 MercadoLibre S.R.L
 #
 #
 #  @license        GNU/GPL, see license.txt
 #  This program is free software: you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation, either version 3 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program.  If not, see http://www.gnu.org/licenses/.
 #



class AssignmentsController < ApplicationController
  belongs_to = :Users
  
  protect_from_forgery
  before_filter :box_values, :only => [:create,:destroy]
<<<<<<< HEAD
  
=======

>>>>>>> c9c7c7bfe8d9be534c8bcf39a498b965a6270f64
  def box_values
       @projects = (Project.find :all).sort_by { |x| x.name.downcase }
       @users    = (User.find :all).sort_by { |x| x.login.downcase }
  end
  
  
  #User projects obtain
  def index
<<<<<<< HEAD
     #@assignments = @project.assignments.find(:all)
=======
>>>>>>> c9c7c7bfe8d9be534c8bcf39a498b965a6270f64
     controller_from = params[:controller_from]
     my_projects = current_user.my_projects
     #Current user last scripts edited
     user_last_edited_scripts = Rails.cache.fetch("circuit_edit_#{current_user.id}"){Hash.new}
     render :partial=>"/layouts/projects", :locals => {:projects => my_projects, :user_last_edited_scripts=>user_last_edited_scripts, :controller_from=>controller_from}  
  end

  def index_other
     controller_from = params[:controller_from]
     all_projects = current_user.other_projects
     #Current user last scripts edited
     user_last_edited_scripts = Rails.cache.fetch("circuit_edit_#{current_user.id}"){Hash.new}
     render :partial=>"/layouts/projects", :locals => {:projects => all_projects, :user_last_edited_scripts=>user_last_edited_scripts, :controller_from=>controller_from}    
  end

<<<<<<< HEAD

  #Other projects obtain
  def show
#     controller_from = params[:controller_from]
#     all_projects = current_user.other_projects
#     #Current user last scripts edited
#     user_last_edited_scripts = Rails.cache.fetch("circuit_edit_#{current_user.id}"){Hash.new}
#     render :partial=>"/layouts/projects", :locals => {:projects => all_projects, :user_last_edited_scripts=>user_last_edited_scripts, :controller_from=>controller_from}      
  end


# Create User Assignment
  def create
    #permit "root" do
     if params[:user_id]
       @project = Project.find params[:project_id]
       @project.assign(params[:user_id])
       flash[:notice] = _("The User has been Assign to the Project") if @project.valid?      
       redirect_to :projects
     else
       redirect_to :projects
     end
    #end
  end

  def update
    #...
  end


# Delete User Assignment
  def destroy
      #permit "root" do
      if params[:user_id]
       @project = Project.find params[:project_id]
       @project.deallocate(params[:user_id])
       flash[:notice] = _("The User has been Deallocate from the Project") if @project.valid?
       redirect_to :projects
      else
       redirect_to :projects
      end
    #end
  end
  
end
=======
# Create User Assignment
  def create
   permit "root" do
       @project = Project.find params[:project_id]
       @user    = User.find params[:user_id]
       @project.assign(params[:user_id]) 
       if !@project.errors.empty?
         @text_error = @project.errors.full_messages
         @js = "top.location='#{edit_project_path(@project.id)}'; alert('#{@text_error}')"
         render :inline => "<%= javascript_tag(@js) %>", :layout => true
       else
         redirect_to edit_project_path(@project.id)
       end
    end
  end

# Delete User Assignment
 def destroy
    permit "root" do
       @project = Project.find params[:id]
       @project.deallocate(params[:user_id])
       if !@project.errors.empty?
         @text_error = _("Unable to deallocate Project Manager")
         @js = "top.location='#{edit_project_path(@project.id)}'; alert('#{@text_error}')"
         render :inline => "<%= javascript_tag(@js) %>", :layout => true
       else
         redirect_to edit_project_path(@project.id)
       end
    end
 end
  

end
>>>>>>> c9c7c7bfe8d9be534c8bcf39a498b965a6270f64
