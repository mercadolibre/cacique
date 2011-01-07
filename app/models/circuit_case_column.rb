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
# Table name: circuit_case_columns
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  circuit_id :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class CircuitCaseColumn < ActiveRecord::Base
  belongs_to :circuit
  has_many :case_data,  :dependent => :destroy
	
	validates_presence_of :circuit_id , :message => _("Must complete circuito_id field")
    validates_presence_of :name, :message => _("Must complete Name field")
    validates_format_of   :name, :with => /^[a-z](_?[a-zA-Z0-9]+)*_?$/, :message => _("Name Formats is not Correct")


end
