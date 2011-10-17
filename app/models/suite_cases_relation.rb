# == Schema Information
# Schema version: 20110630143837
#
# Table name: suite_cases_relations
#
#  id                  :integer(4)      not null, primary key
#  suite_id            :integer(4)
#  case_origin         :integer(4)
#  case_destination    :integer(4)
#  created_at          :datetime
#  updated_at          :datetime
#  circuit_origin      :integer(4)
#  circuit_destination :integer(4)
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
class SuiteCasesRelation < ActiveRecord::Base
  belongs_to :suite
  has_one :circuits
  has_one :case_templates

  validates_presence_of  :suite_id, :message => _("Must complete Suite Field")
  validates_presence_of  :case_origin, :message => _("Must complete case_origin")
  validates_presence_of  :case_destination, :message => _("Must complete case_destination")
  validates_presence_of  :circuit_origin, :message => _("Must complete circuit_origin")
  validates_presence_of  :circuit_destination, :message => _("Must complete circuit_destination")

end
