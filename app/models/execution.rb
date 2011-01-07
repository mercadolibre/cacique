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
# Table name: executions
#
#  id                 :integer(4)      not null, primary key
#  circuit_id         :integer(4)
#  time_spent         :integer(4)      default(0)
#  user_id            :integer(4)
#  case_template_id   :integer(4)
#  suite_execution_id :integer(4)
#  status             :integer(4)      default(0)
#  error              :text
#  position_error     :text
#  worker_pid         :string(255)
#  output             :text
#  created_at         :datetime
#  updated_at         :datetime
#

class Execution < ActiveRecord::Base
  belongs_to :suite_execution
  belongs_to :case_template
  belongs_to :user
  belongs_to :circuit
  has_many :data_recoveries, :dependent => :destroy
  has_many :execution_snapshots, :dependent => :destroy

  validates_presence_of :circuit_id, :message => _("Must complete circuit_id")
  validates_presence_of :user_id, :message => _("Must complete User Field")
  validates_presence_of :case_template_id, :message => _("Must complete case_template_id")
  validates_presence_of :status, :message => _("Must complete Status Fiel")

  after_create  :load_execution_in_cache
  before_destroy :last_in_suite_execution
  
  def error= (e_text)
	  e_text = _("Execution Aborted by User") if e_text =~ /^Interrupted system call/
	  super(e_text)
  end

  def filtered_data_recoveries
    data_recovery_names = circuit.data_recovery_names.map{|drn| drn.name }
    data_recoveries.select{|dr| data_recovery_names.include?(dr.data_name) }
  end
  
  def load_execution_in_cache
    if self.suite_execution_id
      #time to spire suite setting
      time_to_expire = CACHE_EXPIRE_SUITE_EXEC
    else
      time_to_expire = CACHE_EXPIRE_EXEC
    end
    #execution caching
    Rails.cache.write("exec_#{self.id}",self,:expires_in => time_to_expire)  
    #last executed test id caching
    Rails.cache.write("user_#{self.user_id}_ct_#{self.case_template_id}",self.id,:expires_in => time_to_expire)
  end
  
  #Returns the string that represents the status
  def s_status
    case self.status
      when 0
        _("Waiting ...")
      when 1
        _("Running ...")
      when 2
        _("Success")
      when 3
        _("Error")
      when 4
        _("Comented")
      when 5
        _("Not Run")
      else
        _("Complete")
    end
  end
  
  def last_in_suite_execution  
     #If the execution is the last in suite execution, must be delete suite execution too   
    if self.suite_execution.executions.length == 1
       #It breaks the relationship of the execution with his suite execution, so that when doing destroy, not try to delete again
       suite_execution = self.suite_execution
       self.suite_execution_id = 0
       self.save
       suite_execution.destroy
    end
  end
  
end
