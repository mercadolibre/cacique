# == Schema Information
# Schema version: 20110630143837
#
# Table name: suite_containers
#
#  id         :integer(4)      not null, primary key
#  times      :integer(4)
#  suite_id   :integer(4)
#  created_at :datetime
#  updated_at :datetime
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
class SuiteContainer < ActiveRecord::Base
  has_many :suite_executions
  belongs_to :suite
  
  validates_presence_of :suite_id, :message => _("Must Select any Suite")
  
  
  def suite_executions_cache(suite_exec_ids=nil)
    SuiteExecution
    Execution

    #suite_executions search in cache
    suite_executions = []
  
    #if I have suite_execution_ids search it in cache. Else search in DB
    if suite_exec_ids
      suite_exec_ids.each do |suite_execution_id|
        all_suite_execution = Rails.cache.fetch("suite_exec_#{suite_execution_id}"){ s = SuiteExecution.find suite_execution_id; [s,s.execution_ids] }
        suite_executions << all_suite_execution[0]
      end
    else
      suite_executions = self.suite_executions
    end
    
    suite_executions
  
  end
  
end
