# == Schema Information
# Schema version: 20110630143837
#
# Table name: circuit_case_columns
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  circuit_id :integer(4)
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
class CircuitCaseColumn < ActiveRecord::Base
  belongs_to :circuit
  has_many :case_data,  :dependent => :destroy
	
  validates_presence_of :circuit_id , :message => _("Must complete circuito_id field")
  validates_presence_of :name, :message => _("Must complete Name field")
  validates_format_of   :name, :with => /^[a-z](_?[a-zA-Z0-9]+)*_?$/, :message => _("Name Formats is not Correct")

  before_destroy  :delete_dependences
  
  #col Delete
  def delete_dependences
    circuit = Circuit.find self.circuit_id
    #SuiteFieldsRelation dependencies delete
      suite_fields_relations =  circuit.suite_fields_relations_origin.find_all_by_field_origin(self.name) +
                                circuit.suite_fields_relations_destination.find_all_by_field_destination(self.name)
      suite_fields_relations.each do |sfr|
        sfr.destroy
      end
    #DataRecoveryName dependencies delete
    data_recovery_names = circuit.data_recovery_names.find_all_by_code( 'data[:' + self.name + ']')
    data_recovery_names.each do |dr|
      dr.destroy
    end
  end
  
  def default?
    delaults = ContextConfiguration.find_all_by_field_default(true).map(&:name)
    !self.name.match(/default_/).nil? and delaults.include?(self.name.split("default_")[1]) #if column name contains "default_" and is included in defaults
  end

end


