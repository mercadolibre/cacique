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
# Table name: execution_configuration_values
#
#  id                       :integer(4)      not null, primary key
#  suite_execution_id       :integer(4)
#  context_configuration_id :integer(4)
#  value                    :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#

class ExecutionConfigurationValue < ActiveRecord::Base
  belongs_to :context_configuration
  belongs_to :suite_execution
  
  validates_presence_of :suite_execution_id, :message => _("Must be associated with a suite_execution")
  validates_presence_of :context_configuration_id, :message => _("Must have an associated configuration")
end
