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


# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include ProjectIdHelper

  helper :all # include all helpers, all the time
  include AuthenticatedSystem
  before_filter :login_required
  before_filter :context_stuff
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '9aa73b170732eb8c4d700ecc6646d327'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password


 def context_stuff
  if current_user
    lang=current_user.language
    setLanguage(lang)
  else
    lang=CACIQUE_LANG
    setLanguage(lang)
  end
 @lang = lang
   if !current_user.nil?
      #actual view
     @action_controller = controller_name() + ":" + action_name()
     @view = Hash.new
     @view = get_view_names()

     #Selected project is an user project?
     @project_id =  params.has_key?(:project_id) ? params[:project_id].to_i : nil  

      #obtain current project
      if params[:project_id].to_i == 0 or @action_controller == 'home_cacique:index'
         @project_actual = nil
      else
        @project_actual =  Project.find params[:project_id].to_i if params[:project_id]
      end
      
     #Slider menu is extended?
     cacique_slider_menu = cookies[:cacique_slider_menu]
     @menu_left_extended = (cacique_slider_menu.nil?)? 0 : cacique_slider_menu.to_i
     if (@menu_left_extended == 1 and (controller_name() == "circuits" or controller_name() == "case_templates"))
        @categories = @project_actual.categories.find_all_by_parent_id "0"
     end

     #Current user last scripts edited
     @user_last_edited_scripts = Rails.cache.fetch("circuit_edit_#{current_user.id}"){Hash.new}
     
  end
 end

  def handle_redirection
        if @current_user && @current_user != :false
		redirect_to PERMISSION_DENIED_REDIRECTION  + "?source_uri=#{CGI.escape( request.request_uri) }"
	else
	redirect_to LOGIN_REQUIRED_REDIRECTION  + "?source_uri=#{CGI.escape( request.request_uri) }"
	end
  end


  def handle_invalid_action( exception, message =  "<center>"+_("Invalid Action")+"</center>")
    begin
      yield
    rescue exception
      render :text => message, :layout => true
    end

  end

  #
  #decode Characters . Ej: x61 --> a
  def decode_char(x)
    if x[0..0] == "x"
      return x[1..-1].to_i(16).chr
    else
      return x
    end
  end

 protected


  def self.active_scaffold_controller_for(klass)
    return "#{klass}Controller".constantize rescue super
  end

  def local_request?
     false
  end



  ###### After this line is all GETTEXT#####
 
 init_gettext "cacique"
  
  def setLanguage(langCode)
    #cookies["lang"] = langCode
    GetText.locale = langCode
  end

 ###########################################

end
