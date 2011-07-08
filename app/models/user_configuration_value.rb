# == Schema Information
# Schema version: 20110630143837
#
# Table name: user_configuration_values
#
#  id                       :integer(4)      not null, primary key
#  user_configuration_id    :integer(4)
#  context_configuration_id :integer(4)
#  value                    :string(255)     default("")
#  created_at               :datetime
#  updated_at               :datetime
#

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
class UserConfigurationValue < ActiveRecord::Base
  belongs_to :context_configuration
  belongs_to :user_configuration
      
  validates_presence_of :context_configuration_id, :message => _("Must have an Associated Configuration")
  validates_presence_of :user_configuration_id, :message => _("Must have an User Configuration associated ")
end
