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
# Table name: case_data
#
#  id                     :integer(4)      not null, primary key
#  circuit_case_column_id :integer(4)
#  case_template_id       :integer(4)
#  data                   :text
#  created_at             :datetime
#  updated_at             :datetime
#



class CaseDatum < ActiveRecord::Base
  belongs_to :case_template
  belongs_to :circuit_case_column
  
  validates_presence_of :circuit_case_column_id, :message => _("Must complete circuit_case_column_id")
  validates_presence_of :case_template_id, :message => _("Must complete case_template_id")

  def column_name
	  self.circuit_case_column.name
  end
  
  def to_label
    "Data"
  end
  
  def save
	case_template.check_access if case_template
	super
  end
end
