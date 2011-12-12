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


class UsersController < ApplicationController
  skip_before_filter :login_required


  def index
    permit "root" do
      @users=User.all
    end
  end

  # render new.rhtml
  def new
    render :layout => "session"
  end

  def create
    cookies.delete :auth_token
    @user = User.create(params[:user])
    if @user.errors.empty?
      msj = _("Your user has been created successfully,<br/> Please contact to ")+ ("#{ADMIN_EMAIL}") + _(" to activate it.")
      flash[:error] = msj
      render "/sessions/new", :layout=>"session"
      # self.current_user = @user
      # redirect_to '/homes'
    else
      render :action => 'new', :layout => "session"
    end
  end

  def password_recovery
    render :layout => "session"
  end


  def change_password
    @user = User.find_by_salt params[:id] if @user.nil?
    render :layout => "session"
  end


  def save_password
    user = User.find params[:id]
    user.password=params[:user][:password]
    user.password_confirmation=params[:user][:password_confirmation]
    if user.save
      self.current_user = user
      user.email_password_changed
      render :text =>"<br>"+_("Password was changed successfully. ")+"<br>"+_(" You will receive an email with information about the change. ")+"<br>"+" <a href='/homes'>"+_("Go to Cacique")+"</a>"
    else
      error_text = '<ul>'
      user.errors.each { |attr,msg| error_text +=  "<li style='color:red; font-size:12px; text-align:left;'> #{msg} </li>"  }
      error_text += '</ul>'
      render :text => error_text
    end
  end


  def email_password_recovery
    server_port = request.port #Obtain port number
    if !params[:user][:login].empty?
      user = User.find_by_login params[:user][:login]
    elsif !params[:user][:email].empty?
      user =  User.find_by_email(params[:user][:email])
    end
    if user.nil?
      render :text => _('User not Exist')
    else
      render :text => _('Your data is being processed. In few minutes you will receive an email to change your password')
      user.email_password_recovery(server_port)
    end
  end


  def access_denied
    @dir = params[:source_uri].split('?')[0].capitalize
  end


  def show_user_form
    if current_user.has_role?("root")
      if params[:user][:id].to_i !=0
        @user=User.find params[:user][:id].to_i
        render :partial => "user_form"
      else
        render :nothing => true
      end
    else
      render :text => _("Access Denied")
    end
  end


  def update
    if current_user.has_role?("root")
      @text_result=Array.new
      @user = User.find params[:id]
      unless @user.update_attributes(params[:user])
        @user.errors.full_messages.each {|error|  @text_result << error}
      end
      render :partial => "update_results"
    else
      render :text => _("Access Denied")
    end
  end


  def update_permitions
    @user = User.find(params[:id])
    if params.include?("permitions")
      if @user.has_role("root") or @user.has_role("root").nil? #if the user has permission to root returns "nil"
        render :text => "<strong>"+_("Role assigned to User")+"</strong>"
      else
        render :text => "<strong>"+_('Is not possible assign role to user')+"</strong>"
      end
    else
        @user.has_no_role("root")
        render :text => _("Permissions Updated Successfully")
    end
  end

  def edit
    @user=current_user
  end

  def update_my_account
    @user = User.find params[:id]
    params[:user][:language]=params[:user][:language].to_s
    if @user.update_attributes(params[:user])
      #redirect_to "/users/my_account"
      @conf = _('Changes have been made successfully')
      @js = "top.location='#{url_for(:controller=>:users , :action=> "edit", :id=>@user.id)}' ; alert('#{@conf}')"
      render :inline => "<%= javascript_tag(@js) %>", :layout => true
    else
      render :action => :edit
    end
  end

end
