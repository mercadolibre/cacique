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
# == Schema Information
# Schema version: 20101129203650
#
# Table name: notes
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  text       :text
#  home       :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

class Note < ActiveRecord::Base

  belongs_to :user


  validates_presence_of  :user_id, :message => _("Impossible create a note without an Assigned User")

  #Devuelve todas las notas con posicion general
  def self.generals
    Note.find(:all, :conditions => "home = true", :order => "updated_at DESC")
  end
  
  def clean_text
    text = self.text
    #Characters are replaced so the view does not fail    
    text = text.dump
    text.gsub!("\"","'")
    text = text.chop
    text[0]=""
    
    text
  end
end
