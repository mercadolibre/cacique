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


# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  skip_before_filter :login_required
 
  # render new.rhtml
  def new
    if logged_in?
      redirect_to '/homes'
    else
     render :layout => "session"
   end
  end

  def create
    if User.active?(params[:login])
      self.current_user = User.authenticate(params[:login], params[:password]) 
      if logged_in?
        if params[:remember_me] == "1"
          current_user.remember_me unless current_user.remember_token?
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end
        redirect_back_or_default('/homes')
        flash[:notice] = _("Wellcome to Cacique!")
      else
        flash[:error] = _("User or Password Incorrect")
        render :action => 'new', :layout => "session"
      end
    else
        flash[:error] = _("User ")+"#{params[:login]}"+_(" is not active.")
        render :action => 'new', :layout => "session"
    end 
 end

  def destroy
    self.current_user.forget_me if logged_in?
    #cookies.delete :cod
    cookies[:auth_token] = { :value => nil, :expires => Time.at(0) }
    cookies[:project_id] = { :value => nil, :expires => Time.at(0) }
    cookies[:cacique_slider_menu] = { :value => nil, :expires => Time.at(0) }
    cookies[:_cacique_session] = { :value => nil, :expires => Time.at(0) }
    cookies[:cod] = { :value => nil, :expires => Time.at(0) }
    reset_session
    flash[:notice] = _("Session Out")
    redirect_back_or_default('/')
  end
end
