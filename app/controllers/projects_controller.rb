 #
 #  @Authors:    
 #      Brizuela Lucia                  lula.brizuela@gmail.com
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


class ProjectsController < ApplicationController
  protect_from_forgery
  before_filter :box_values, :only => [:index,:new,:edit,:assign,:deallocate]
  skip_before_filter :context_stuff, :only => [:get_all_projects, :get_my_projects]
  
  #get values about projects and users that will be showed on projects selects
  def box_values
       @projects = (Project.find :all).sort_by { |x| x.name.downcase }
       @users    = (User.find :all).sort_by { |x| x.login.downcase }
  end

  def index
    permit "root" do
    end
  end

  def new
    permit "root" do
       unless params[:project].nil?
         
         projectname = params[:project].to_s
         if projectname.match(/'+/)
           flash[:notice] = _("ATENTION: Project Name can´t contain single quotes")
           render :index         
         else
           @project = Project.create(params[:project])
           @project.creater_user_relation(params[:project][:user_id])
           flash[:notice] = _("The Project was Correctly Create") if @project.valid?
           render :index
         end
       
       else
         redirect_to :projects
       end
       
    end
  end

  def edit
    permit "root" do
      if params[:user_id]
        @project = Project.find params[:project_id]
        @project.update_attributes(params[:project])
        @project.assign_manager(params[:user_id])
        flash[:notice] = _("The Project was Correctly Modified") if @project.valid?
        render :index
      else
        redirect_to :projects
      end
    end
  end


  #user - project relation create
  def assign
    permit "root" do
     if params[:user_id]
       @project = Project.find params[:project_id]
       @project.assign(params[:user_id])
       flash[:notice] = _("The User has been Assign to the Project") if @project.valid?
       render :index
     else
       redirect_to :projects
     end
    end
 end

  #user - project relation delete
  def deallocate
    permit "root" do
      if params[:user_id]
       @project = Project.find params[:project_id]
       @project.deallocate(params[:user_id])
       flash[:notice] = _("The User has been Deallocate from the Project") if @project.valid?
       render :index
      else
       redirect_to :projects
      end
    end
  end

  #User project obtain
  def get_all_projects
     controller_from = params[:controller_from]
     all_projects = current_user.other_projects
     #Current user last scripts edited
     user_last_edited_scripts = Rails.cache.fetch("circuit_edit_#{current_user.id}"){Hash.new}
     render :partial=>"/layouts/projects", :locals => {:projects => all_projects, :user_last_edited_scripts=>user_last_edited_scripts, :controller_from=>controller_from}   

  end

  def get_my_projects
     controller_from = params[:controller_from]
     my_projects = current_user.my_projects
     #Current user last scripts edited
     user_last_edited_scripts = Rails.cache.fetch("circuit_edit_#{current_user.id}"){Hash.new}
     render :partial=>"/layouts/projects", :locals => {:projects => my_projects, :user_last_edited_scripts=>user_last_edited_scripts, :controller_from=>controller_from}  
  end

end
