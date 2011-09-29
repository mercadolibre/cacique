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

  def index
    @projects     = Project.find(:all, :order => "name")
    @project_id   = params[:filter] ? params[:filter][:project_id].to_s : ""
    params[:text] = params[:filter][:text]  if( params[:filter] and params[:filter][:text] ) #Search
    @public = params[:visibility] = true if(params[:filter] and params[:filter][:project_id] == "0") #Public functions
    @search = UserFunction.get_user_functions_with_filters([@project_id], params)   
    @user_functions = @search.paginate :page => params[:page], :per_page => 20
    @param_search   = ( !params[:filter].nil? ?  params[:filter][:text] : nil )
    @has_permission = current_user.has_permission_admin_project?(@project_id)
    @users = User.all
  end

  def search
     params_filter     = {}
     @user_functions   = []
     if params[:filter] 
       params_filter = params[:filter]
       #Visibility 
       if params[:filter][:visibility]
          params[:filter][:visibility].empty? ? params_filter.delete(:visibility) : params_filter[:visibility] = (params[:filter][:visibility] == "true")
       end
       #All projects
       params_filter[:projects_ids] = [] if ( !params[:filter][:projects_ids] or params[:filter][:projects_ids].first == "0" ) 
       #Projects and visibility
       if( !params[:filter][:visibility].nil? and !params[:filter][:projects_ids].empty? )
          params_filter[:logic] = Hash.new
          params_filter[:logic] = "and" 
       end
    end
    @search         = UserFunction.get_user_functions_with_filters(params_filter[:projects_ids],params_filter) if !params_filter.empty?
    @user_functions = @search.paginate :page => params[:page], :per_page => 20 if @search
    @projects       = Project.find(:all, :order => "name")
    @users          = User.all
    @has_permission =  current_user.has_permission_admin_project?(@project_id)
  end

  def new
    @has_permission = current_user.has_permission_admin_project?(params[:project_id])
    if @has_permission
      @user_function = UserFunction.new
      @user_function.project_id = params[:project_id]
      @arguments = []
    else
      redirect_to "/users/access_denied?source_uri=user_functions"
    end
  end

  def find
    #search all project functions
    params[:visibility] = true
    params[:logic]      = "or"
    params[:text]       = params[:filter][:text]  if( params[:filter] and params[:filter][:text] )
    @user_functions = UserFunction.get_user_functions_with_filters([0, params[:project_id]],params) 
    render :partial => "/circuits/functions", :locals => {:user_functions => @user_functions, :param_search => "", :project_id=>@project_id}
  end

  def create
    @has_permission = current_user.has_permission_admin_project?(params[:user_function][:project_id])
    if @has_permission
      args = UserFunction.prepare_args(params[:user_function][:args]) 
    
      @user_function = UserFunction.new(:user_id => current_user.id,
                                        :name => params[:user_function][:name],
                                        :description => params[:user_function][:description],
                                        :project_id => params[:user_function][:project_id],
                                        :cant_args => args.length,
                                        :example => params[:user_function][:example],
                                        :visibility => (params[:user_function][:visibility] == "1" ? true : false),
                                        :hide => (params[:user_function][:hide] == "1" ? true : false) )
                                     
      #source_code Generate
      code = params[:user_function][:code].split("_")[1..-1].map{|x| decode_char(x) }.join
      @user_function.source_code = @user_function.generate_source_code(code, params[:user_function][:name], args)

      if @user_function.save
        @func_mod = _("Function was created Successfuly")
        # function create confirmation and redirect to function list
        @js = "top.location='/user_functions/#{@user_function.id}/edit' ; alert('#{@func_mod}')"
        render :inline => "<%= javascript_tag(@js) %>", :layout => true
      else
        @source_code = code
        @arguments = args
        render :action => "new"    
      end
    
    else
      redirect_to "/users/access_denied?source_uri=user_functions"
    end
  end  
  
  
  def edit
    @user_function = UserFunction.find params[:id]
    @has_permission = current_user.has_permission_admin_project?(@user_function.project_id)
    if @has_permission and !@user_function.hide?
      #Version
      if params[:version]
        @user_function.revert_to( params[:version].to_i )
        @version_number = params[:version].to_i
      end
      @previous_version = @user_function.find_version('max')
      @next_version     = @user_function.find_version('min')
      @source_code      = @user_function.show_source_code
      @arguments        = @user_function.show_arguments 
      last_modifier     = @user_function.versions.last
      @last_modifier    = (last_modifier)? User.find(last_modifier.user_id) : @user_function.user
    else
      redirect_to "/users/access_denied?source_uri=user_functions"
    end
  end
  
  def show
    @user_function  = UserFunction.find params[:id]
    @project_id     = params[:project_id].to_i
    @source_code      = @user_function.show_source_code
    @arguments        = @user_function.show_arguments 
    last_modifier     = @user_function.versions.last
    @last_modifier    = (last_modifier)? User.find(last_modifier.user_id) : @user_function.user
  end
  
  def update
    @user_function = UserFunction.find params[:id]
    @has_permission = current_user.has_permission_admin_project?(@user_function.project_id)
    if @has_permission and !@user_function.hide?
      args = UserFunction.prepare_args(params[:user_function][:args]) 
      @user_function.name = params[:user_function][:name]
      @user_function.description = params[:user_function][:description].to_s
      @user_function.cant_args = args.length
      @user_function.example = params[:user_function][:example]
      @user_function.visibility = (params[:user_function][:visibility] == "1" ? true : false)
      @user_function.hide = (params[:user_function][:hide] == "1" ? true : false)
      #source_code Generate
      code=params[:user_function][:code].split("_")[1..-1].map{|x| decode_char(x) }.join
      @user_function.source_code = @user_function.generate_source_code(code, params[:user_function][:name], args)
      @user_function.save 
      @success = _('Function was successfuly updated')
      respond_to do |format|
         format.html
         format.js # run the confirm.rjs template
      end
    else
      redirect_to "/users/access_denied?source_uri=user_functions"
    end
  end


  def delete
    @user_function = UserFunction.find params[:id]
    @has_permission = current_user.has_permission_admin_project?(@user_function.project_id)
    if @has_permission
      if @user_function.destroy
        @func_mod =  _("Function was successfully removed")
        @js = "top.location='/user_functions?filter[project_id]=#{@user_function.project_id}'; alert('#{@func_mod}')"
        render :inline => "<%= javascript_tag(@js) %>", :layout => true
      else
        text_error = Array.new
        func_mod = @user_function.errors.full_messages.each {|error|  text_error << error }   
        @func_mod = func_mod.join(', ') 
        @js = "top.location='/user_functions'; alert('#{@func_mod}')"
        render :inline => "<%= javascript_tag(@js) %>", :layout => true
      end  
    else
      redirect_to "/users/access_denied?source_uri=user_functions"
    end
  end
  
  
  def show_move
    @user_function = UserFunction.find params[:id]
    @has_permission = current_user.has_permission_admin_project?(@user_function.project_id)
    if @has_permission
      #Projects to which I have permission to move the function
      #With the format [[name, id],[name2, id2]]
      @projects = @user_function.find_projects_to_move(current_user)
      @projects =  [[_('Generals'), 0]] + @projects if (current_user.has_role?("root") and @user_function.project_id != 0)
      render :partial => "move", :locals => { :user_function => @user_function, :projects => @projects, :can_move_to_generico => @can_move_to_generico }
    else
      redirect_to "/users/access_denied?source_uri=user_functions"
    end
  end
  
  
  def move
    @user_function = UserFunction.find params[:id]
    if !params[:user_function].nil?
      #To Generic
      if params[:user_function][:project] == 0
        redirect = "/user_functions"
      else
        redirect =  "/user_functions?filter[project_id]=#{params[:user_function][:project]}"   
      end

      project_id = params[:user_function][:project]   
      @has_permission = current_user.has_permission_admin_project?(@user_function.project_id) and current_user.has_permission_admin_project?(project_id)
      if @has_permission
        if @user_function.move_project(project_id)
          @func_mov = _('Function was successfuly moved')
          @js = "top.location='#{redirect}'; alert('#{@func_mov}')"
          render :inline => "<%= javascript_tag(@js) %>", :layout => true
        else
          text_error = []
          func_mod = @user_function.errors.full_messages.each {|error|  text_error << error }   
          @func_mod = func_mod.join(', ') 
          @js = "top.location='/user_functions'; alert('#{@func_mod}')"
          render :inline => "<%= javascript_tag(@js) %>", :layout => true
        end
      else
        redirect_to "/users/access_denied?source_uri=user_functions"
      end
    else
      @func_mov = _('Could not move the function')
      @js = "top.location='/user_functions'; alert('#{@func_mov}')"
      render :inline => "<%= javascript_tag(@js) %>", :layout => true
    end
  end

  #scripts using the function
  def user_function_uses
    @user_function = UserFunction.find params[:id]
    @scripts = Circuit.find(:all, :conditions=>["source_code like ? ", '%' + @user_function.name + '%'])
    render :partial => "user_function_users", :locals => {:user_function =>@user_function, :scripts => @scripts,}
  end
  
  
end
