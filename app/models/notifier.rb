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
class Notifier < ActionMailer::Base
  
  # Sends mails to new users with their login and password information.
  def signup_mail(user)
   @recipients = user.email
   @from = EMAIL
   @subject = _("[Cacique] Welcome!!!")
   @body['user'] = user
   @content_type = "text/html"
  end

  #password recovery mail
  def password_recovery(user, server_port)
   @recipients = user.email
   @from = EMAIL
   @subject = _("[Cacique] Password Recovery")
   @body['user'] = user
   @body['url'] = "http://" + IP_SERVER.to_s + ":" + server_port.to_s + "/users/change_password/" + user.salt.to_s
   @content_type = "text/html"
  end

  #password recovery mail answer
  def password_changed(user)
   @recipients = user.email
   @from = EMAIL
   @subject = _("[Cacique] Password Change")
   @body['user'] = user
   @content_type = "text/html"
  end

  def suite_execution_alert(suite_execution,emails_to_send)
    @recipients = emails_to_send
    @from = EMAIL
    @subject = _("[Cacique] Suite Execution Detail")
    @body['suite_execution'] = suite_execution
    @content_type = "text/html"
  end 
  
  def execution_single_alert(suite_execution,emails_to_send)
      @execution = Execution.find suite_execution.execution_ids[0]
      
      @recipients = emails_to_send
      @from = EMAIL
      @subject = _("[Cacique] Case ")+ @execution.case_template_id.to_s + _(": Execution Detail ")
      @body['execution'] = @execution
      @content_type = "text/html"
  end

end
