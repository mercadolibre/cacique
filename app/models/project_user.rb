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
# Table name: project_users
#
#  id         :integer(4)      not null, primary key
#  project_id :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

# == Schema Information
# Schema version: 20091126193447
#
# Table name: project_users
#
#  id         :integer         not null, primary key
#  project_id :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#
class ProjectUser < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  validates_presence_of :project_id, :message => _("Must complete Project Field")
  validates_presence_of :user_id, :message => _("Must complete User Field")

  before_save    :assign_roles
  before_destroy :deallocate_roles


  def assign_roles
    #assign editor rol to user
    user    = User.find self.user_id
    project = Project.find self.project_id
	  user.has_role("editor", project)
	  user.has_role("viewer", project)
  end

  def deallocate_roles
    # unassign editor rol  to user
    user = User.find self.user_id
    project = Project.find self.project_id
	  user.has_no_role("editor", project)
	  user.has_no_role("viewer", project)
  end

end
