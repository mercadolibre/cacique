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
# Table name: delayed_jobs
#
#  id              :integer(4)      not null, primary key
#  priority        :integer(4)      default(0)
#  attempts        :integer(4)      default(0)
#  handler         :text
#  last_error      :text
#  run_at          :datetime
#  locked_at       :datetime
#  failed_at       :datetime
#  locked_by       :text
#  created_at      :datetime
#  updated_at      :datetime
#  task_program_id :integer(4)
#  status          :integer(1)      default(1)
#

require "#{RAILS_ROOT}/lib/run_suite_program.rb"
class DelayedJob < ActiveRecord::Base
  belongs_to :suite
  
  def add_suite_id(suite_id)
    self.suite_id = suite_id
    self.save
  end
  
end
