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
# Table name: context_configurations
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  view_type     :string(255)
#  values        :text
#  field_default :boolean(1)
#  enable        :boolean(1)      default(TRUE)
#  created_at    :datetime
#  updated_at    :datetime
#

class ContextConfiguration < ActiveRecord::Base
  has_many :user_configuration_values, :dependent => :destroy
  has_many :execution_configuration_values
  
  validates_presence_of :name, :message => _(" - Must complete Name field")
  validates_format_of :name, :with => /^[a-z]([a-zA-Z0-9]*\_?)*$/, :message => _(" - Must enter a name with numbers, letters or underscore")
  validates_presence_of :view_type, :message => _(" - Must complete a View Mode")
  validates_uniqueness_of :name, :message => _(" - Already exists a Configuration with that name"), :if => Proc.new { |c| c.enable and !ContextConfiguration.find(:all, :conditions => "enable = true AND name = '#{c.name}' #{(c.id.nil? ? '' : ' and id != ' + c.id.to_s)}").empty?}


  before_validation  :verify_values

  def verify_values
    #Checkbox, select and radiobutton must have motre than one value
    self.errors.add( :values, '- For the Type of View selected, you must enter at least 1 value') if ['checkbox', 'select', 'radiobutton'].include?self.view_type and self.values.split(";").count < 1
    self.errors.empty?
  end

  def self.all_enable
    ContextConfiguration.find_all_by_enable true
  end
  
  def add_values(values)
    self.values = values.values.uniq.delete_if{|x| x == "" }.join(";")
  end
  
  #if configuration==enable return true
  def enable?
    self.enable
  end
  
  #return true if status == 'disabled'
  def disable?
    !self.enable
  end
  
  #return an Array of Values
  def all_values
    self.values.split(";")
  end
  
  def process_values(values, value, view_type)
    if view_type == 'checkbox' or view_type == 'radiobutton' or view_type == 'select'
      #add the value "default" if field_default now is active and is not included yet
      values["value0"]= "default" if  self.field_default
      add_values(values)
    elsif view_type == 'input' or view_type == 'boolean'
      add_values(:value => value)
    else
      errors.add_to_base "#{view_type}"+_('View Type not Exists')+" \n"
    end
  end
  
  #Add Field
  def add_configuration_to_all_user()
    UserConfiguration.all.each do |user_configuration|
      user_configuration.add_user_configuration_value(self.id,"")
    end
  end
  
  #Delete all user configurations
  def delete_all_user_configuration_values()
    self.user_configuration_values.each do |user_configuration_value|
      user_configuration_value.destroy
    end
  end
  
  def disable
    self.enable = false
    self.save
    self.delete_all_user_configuration_values()
  end
  
  def self.calculate_columns
    @context_configurations = ContextConfiguration.all_enable
    if @context_configurations.count == 1
      @column_1 = [@context_configurations[0]]
      @column_2 = []
    else
      cant_for_column = (@context_configurations.count/2) 
      @column_1 = @context_configurations[0..(cant_for_column-1)]
      @column_2 = @context_configurations[cant_for_column..@context_configurations.count]
    end
    return @column_1, @column_2
  end

  def self.build_select_data
    #Build the selects for edit cell in case template
    cell_selects = Hash.new #Format: {column_name => values}
    context_configurations = ContextConfiguration.find(:all, :conditions => "enable = '1' AND field_default = 1")
    context_configurations.each do |context_configuration|
      values = Array.new
      values = context_configuration.values.split(";")
      values.delete("default")
      cell_selects["default_" + context_configuration.name] = values
    end
    cell_selects
  end


   def  modify_data_column_name
        #Verify if the column already exists in Cacique
        circuits = Circuit.circuits_with_column(self.name)
        if !circuits.empty?  
          circuits.each do |c|
              self.errors.add(:name,_("Column ")+"#{self.name}"+_(", already exist in Data Set belonging to Script ")+"#{c.name}")
            end
        else        
          #Add the column of context_configuration.field_default
          circuits   = Circuit.all
          old_column = "default_" + self.changes["name"][0]
          new_column = "default_" + self.name
          circuits.each do |c|
             c.modify_case_columns( old_column, new_column )
          end
        end
        self
   end    
  
   
    def  add_data_column_name
        #Verify if the column already exists in Cacique
        circuits = Circuit.circuits_with_column(self.name)
        if !circuits.empty?  
          circuits.each do |c|
              self.errors.add(:name,_("Column ")+"#{self.name}"+_(" , already exist in Data Set belonging to Script ")+"#{c.name}")
            end
        else        
          #Add the column of context_configuration.field_default
          circuits = Circuit.all
          column_name = "default_" + self.name 
          circuits.each do |c|
             c.add_case_columns( column_name )
          end
        end     
      self
    end  
    
    def  delete_data_column_name
      #Delete the column of context_configuration.field_default
      circuits = Circuit.all
      column_name = "default_" + self.name 
      circuits.each do |circuit|
        circuit_column_name = CircuitCaseColumn.find(:first, :conditions=>["circuit_id = ? AND name = ?",circuit.id, column_name])
        circuit_column_name.destroy
      end    
     self
    end  

end
