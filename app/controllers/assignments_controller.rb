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
  
 # protect_from_forgery
  before_filter :box_values, :only => [:create,:destroy]

  def box_values
       @projects = Project.all.sort
       @users    = User.all.sort
  end
  
  
  #User projects obtain
  def index
     controller_from = params[:controller_from]
     my_projects = current_user.my_projects
     #Current user last scripts edited
     user_last_edited_scripts = Rails.cache.fetch("circuit_edit_#{current_user.id}"){Hash.new}

     respond_to do |format|
       format.html { render :partial=>"/layouts/projects", :locals => {:projects => my_projects, :user_last_edited_scripts=>user_last_edited_scripts, :controller_from=>controller_from} }
       format.text {render :text => my_projects.inspect}
       format.json {render :json => my_projects.to_json}
       format.xml  {render :xml => my_projects.to_xml}
     end
  end

def index_other
     controller_from = params[:controller_from]
     all_projects = current_user.other_projects
     #Current user last scripts edited
     user_last_edited_scripts = Rails.cache.fetch("circuit_edit_#{current_user.id}"){Hash.new}
     
     respond_to do |format|
       format.html {render :partial=>"/layouts/projects", :locals => {:projects => all_projects, :user_last_edited_scripts=>user_last_edited_scripts, :controller_from=>controller_from}}
       format.text {render :text => all_projects.inspect}
       format.json {render :json => all_projects.to_json}
       format.xml  {render :xml => all_projects.to_xml}
     end
  end

# Create User Assignment
  def create
    @project = Project.find params[:project_id]
    @user    = User.find params[:user_id]
    permit "root or (manager of :project)" do
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
    @project = Project.find params[:id]
    permit "root or (manager of :project)" do
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
