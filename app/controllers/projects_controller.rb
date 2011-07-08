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
 # protect_from_forgery
  before_filter :box_values, :only => [:index,:create,:update,:destroy,:assign,:deallocate]
  #skip_before_filter :context_stuff, :only => [:get_all_projects, :get_my_projects]
  
  #get values about projects and users that will be showed on projects selects
  def box_values
       @projects = (Project.find :all).sort_by { |x| x.name.downcase }
       @users    = (User.find :all).sort_by { |x| x.name.downcase }
  end


#curl -X GET -H "Accept: text/plain" localhost:3000/projects -d api_key=268e7639fbd4d54656bd4393ee50941414621dc7
#curl -X GET -H "Accept: application/xml" localhost:3000/projects -d api_key=268e7639fbd4d54656bd4393ee50941414621dc7
#curl -X GET -H "Accept: application/json" localhost:3000/projects -d api_key=268e7639fbd4d54656bd4393ee50941414621dc7

def index
    permit "root" do
      respond_to do |format|
        format.html
        format.text {render :text => @projects.inspect}
        format.xml {render :xml=>@projects.to_xml}
        format.json {render :json=>@projects.to_json}
      end
    end  
 
  end

  def show
  
  end

  def create
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
           redirect_to :projects
         end
       
       else
         redirect_to :projects
       end
       
    end
  end

  def edit
     @project    = Project.find params[:id]
     @assigments = ProjectUser.find_all_by_project_id @project.id
     @users      = User.all.sort_by { |x| x.name.downcase }
  end

  def update
    permit "root" do
        @project = Project.find params[:id]
        @project.update_attributes(params[:project])
        #update mannager
        @project.assign_manager(params[:project][:user_id]) 
        flash[:notice] = _("The Project was Correctly Modified") if !@project.errors.empty?
        redirect_to edit_project_path(@project.id)
    end
  end

  def destroy
#   TO DO
  end


end
