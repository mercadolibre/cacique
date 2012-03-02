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
  # before_filter :box_values, :only => [:index,:create,:update,:destroy,:assign,:deallocate]
  before_filter :has_permission, :only => [:edit, :update, :destroy]
  
  def has_permission
    @project = Project.find params[:id]
    permit "root or (manager of :project)"
  end

#curl -X GET -H "Accept: text/plain" localhost:3000/projects -d api_key=268e7639fbd4d54656bd4393ee50941414621dc7
#curl -X GET -H "Accept: application/xml" localhost:3000/projects -d api_key=268e7639fbd4d54656bd4393ee50941414621dc7
#curl -X GET -H "Accept: application/json" localhost:3000/projects -d api_key=268e7639fbd4d54656bd4393ee50941414621dc7

  def index
    @projects = Project.all.sort
    @users    = User.all.sort
    @is_root  = current_user.has_role? "root"
  end

  def show
  
  end

  def create
    if params[:project]
      # if current_user is not root, it's assigned as a manager (can't assign another user)
      params[:project][:user_id] = current_user.id if params[:project][:user_id].blank? || current_user.has_no_role?("root")
      @project = Project.create(params[:project])

      flash[:notice] = _("The Project was Correctly Create") if @project.valid?
    end
    redirect_to :projects
  end

  def edit
    @assigments = ProjectUser.find_all_by_project_id @project.id
    @users      = User.all.select{|u| u.active?}.sort_by { |x| x.name.downcase }
  end

  def update
    @project.update_attributes(params[:project])
    @project.assign_manager(params[:project][:user_id])
    flash[:notice] = _("The Project was Correctly Modified") if !@project.errors.empty?
    redirect_to edit_project_path(@project.id)
  end

  def destroy
#   TO DO
  end


end
