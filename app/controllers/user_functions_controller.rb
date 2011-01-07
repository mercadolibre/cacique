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


class UserFunctionsController < ApplicationController
  permit "root" , :only => [:index, :show_move, :move]

  def index
    @search = UserFunction.find(:all, :conditions=>"project_id = 0 and name like '%#{params[:search].to_s}%' or description like '%#{params[:search].to_s}%'", :order=> "name ASC")
    @user_functions = @search.paginate :page => params[:page], :per_page => 20
    (!params[:search].nil?)? @param_search = params[:search] : @param_search = ""
    @can_move = true
  end


  def new
      @user_function = UserFunction.new
      @user_function.project_id = params[:project_id]
      @readonly = !current_user.has_role?("root")
      @arguments = []
  end


  def per_project
    #Searching all projects to which the user has permissions
    @projects = current_user.my_projects_admin.collect{ |x| [x.name.downcase,x.id] }
  end
  
  
  def find
    if params[:project_id].empty?
      #Se marco la opcion "Seleccione" del select de proyectos
      render :nothing => true
    else
      @project = Project.find params[:project_id]
      @user_functions = UserFunction.find(:all, :conditions=>"project_id = #{@project.id} and ( name like '%#{params[:search].to_s}%' or description like '%#{params[:search].to_s}%')", :order=> "name ASC")
      (!params[:search].nil?)? @param_search = params[:search] : @param_search = ""
      @can_move = current_user.has_role?("root")
      render :partial => "functions_per_project", :locals => {:user_functions => @user_functions, :project_id => @project.id, :search => @param_search, :can_move => @can_move } 
    end
    
  end


  def find_per_project
    #search all project functions
	  @methods = UserFunction.find(:all,  :order => 'name ASC', :conditions => ["project_id = 0 or project_id = ?", params[:project_id]])  
    render :partial => "/circuits/functions", :locals => {:methods => @methods}
  end


  def create
    if (params[:user_function][:project_id]!= "0" and current_user.my_projects_admin.include?( Project.find(params[:user_function][:project_id]))) or current_user.has_role?("root")
      #Delete all empty parameters
      args = []
      if !params[:user_function][:args].nil?
        params[:user_function][:args].delete_if{|k,v| v== ""}
        aux_args = params[:user_function][:args]
        aux_args.to_a.sort.each do |arg|
          args << arg[1]
        end
      end  
    
      @user_function = UserFunction.new(:user_id => current_user.id,
                                        :name => params[:user_function][:name],
                                        :description => params[:user_function][:description],
                                        :project_id => params[:user_function][:project_id],
                                        :cant_args => args.length)
                                     
      #source_code Generate
      code=params[:user_function][:code].split("_")[1..-1].map{|x| decode_char(x) }.join
      source_code = @user_function.generate_source_code(code, params[:user_function][:name], args)

      @user_function.source_code = source_code

      if @user_function.save
        @func_mod = _("Function was created Successfuly")
        if params[:user_function][:project_id] == "0"
          # function create confirmation and redirect to function list
          @js = "top.location='/user_functions'; alert('#{@func_mod}')"
          render :inline => "<%= javascript_tag(@js) %>", :layout => true
        else
          @js = "top.location='/user_functions/per_project'; alert('#{@func_mod}')"
          render :inline => "<%= javascript_tag(@js) %>", :layout => true
        end  
      else
        @user_function.source_code = params[:user_function][:source_code]
        @source_code=params[:user_function][:code].split("_")[1..-1].map{|x| decode_char(x) }.join
        @arguments = args
        render :action => "new"    
      end
    
    else
      redirect_to "/users/access_denied?source_uri=user_functions"
    end
  end  
  
  
  def edit
    @user_function = UserFunction.find params[:id]
    @source_code   = @user_function.show_source_code
    @arguments     = @user_function.show_arguments
    #Edit permission
    @readonly = !current_user.has_role?("root")
  end
  
  
  def update
    @user_function = UserFunction.find params[:id]
    if (@user_function.project_id != 0 and current_user.my_projects_admin.include?( Project.find(@user_function.project_id))) or current_user.has_role?("root")
      #Delete all empty parameters
      args = []
      if !params[:user_function][:args].nil?
        params[:user_function][:args].delete_if{|k,v| v== ""}
        aux_args = params[:user_function][:args]
        aux_args.to_a.sort.each do |arg|
          args << arg[1]
        end
      end 

      @user_function.name = params[:user_function][:name]
      @user_function.description = params[:user_function][:description].to_s
      @user_function.cant_args = args.length
    
      #source_code Generate
      code=params[:user_function][:code].split("_")[1..-1].map{|x| decode_char(x) }.join
      source_code = @user_function.generate_source_code(code, params[:user_function][:name], args)
      @user_function.source_code = source_code
    
      if @user_function.save
        @func_mod = _("Function was updated Successfuly")
        if @user_function.project_id == 0
          @js = "top.location='/user_functions'; alert('#{@func_mod}')"
          render :inline => "<%= javascript_tag(@js) %>", :layout => true
        else
          @js = "top.location='/user_functions/per_project'; alert('#{@func_mod}')"
          render :inline => "<%= javascript_tag(@js) %>", :layout => true
        end
      else
        @user_function.source_code = params[:user_function][:source_code]
        @source_code=params[:user_function][:code].split("_")[1..-1].map{|x| decode_char(x) }.join
        @arguments = args
        render :action => "edit"
      end 
    
    else
      redirect_to "/users/access_denied?source_uri=user_functions"
    end
  end


  def delete
    @user_function = UserFunction.find params[:id]
    if ( @user_function.project_id != 0 and current_user.my_projects_admin.include?( @user_function.project )) or current_user.has_role?("root")
      project_id = @user_function.project_id
      if @user_function.destroy
        if project_id == 0
          @func_mod =  _("Function was successfully removed")
          @js = "top.location='/user_functions'; alert('#{@func_mod}')"
          render :inline => "<%= javascript_tag(@js) %>", :layout => true
        else
          @func_mod =  _("Function was successfully removed")
          @js = "top.location='/user_functions/per_project'; alert('#{@func_mod}')"
          render :inline => "<%= javascript_tag(@js) %>", :layout => true
        end
      else
        @func_mod =  _("This function can not be Deleted")
        @js = "top.location='/user_functions'; alert('#{@func_mod}')"
        render :inline => "<%= javascript_tag(@js) %>", :layout => true
      end
    
    else
      redirect_to "/users/access_denied?source_uri=user_functions"
    end
  end
  
  
  def show_move
    @user_function = UserFunction.find params[:id]
    #Projects to which I have permission to move the function
    #With the format [[name, id],[name2, id2]]
    @projects = @user_function.find_projects_to_move(current_user)
    @can_move_to_generico = (current_user.has_role?("root") and @user_function.project_id != 0)
    render :partial => "move", :locals => { :user_function => @user_function, :projects => @projects, :can_move_to_generico => @can_move_to_generico }
  end
  
  
  def move
    @user_function = UserFunction.find params[:id]
    if !params[:user_function].nil?
      if params[:user_function].include?(:move_generico)
        project_id = 0
        redirect = "/user_functions"
      else
        project_id = params[:user_function][:project]
        redirect = "/user_functions/per_project"
      end
    
      if @user_function.move_project(project_id)
        @func_mov = _('Se movio correctamente la funcion')
        @js = "top.location='#{redirect}'; alert('#{@func_mov}')"
        render :inline => "<%= javascript_tag(@js) %>", :layout => true
      else
        @func_mov = _('No se pudo mover la funcion')
        @js = "top.location='#{redirect}'; alert('#{@func_mov}, #{@user_function.errors.first[1].to_s.gsub!('\n',"")}')"
        render :inline => "<%= javascript_tag(@js) %>", :layout => true
      end
    else
      @func_mov = _('No se pudo mover la funcion')
      @js = "top.location='/user_functions'; alert('#{@func_mov}')"
      render :inline => "<%= javascript_tag(@js) %>", :layout => true
    end
  end
  
  
end
