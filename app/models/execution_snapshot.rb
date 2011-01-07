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
# Table name: execution_snapshots
#
#  id           :integer(4)      not null, primary key
#  execution_id :integer(4)
#  name         :string(255)
#  content      :text
#  created_at   :datetime
#  updated_at   :datetime
#

class ExecutionSnapshot < ActiveRecord::Base
  belongs_to :execution

  EXECUTION_SNAPSHOT_LIMIT = 5000

  validates_presence_of :execution_id, :message => _("Must complete navegar_item_id Field")
  validates_presence_of :content, :message => _("Must complete Content Field")
  validates_presence_of :name, :message => _("Must complete Name Field")

  def save

    if ExecutionSnapshot.count >= EXECUTION_SNAPSHOT_LIMIT
        es = ExecutionSnapshot.first
        es.delete
        es.save
    end
    super
  end
end
