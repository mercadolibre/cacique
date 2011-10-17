# == Schema Information
# Schema version: 20110630143837
#
# Table name: case_templates
#
#  id         :integer(4)      not null, primary key
#  circuit_id :integer(4)
#  user_id    :integer(4)
#  objective  :string(255)
#  priority   :string(255)
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
class CaseTemplate < ActiveRecord::Base
  belongs_to :user
  belongs_to :circuit
  has_many :executions, :dependent => :destroy
  has_many :case_data, :dependent => :destroy
  has_many :schematics,  :dependent => :destroy
  has_many :suite_cases_relations_origin,      :foreign_key => :case_origin     , :dependent => :destroy,  :class_name=>"SuiteCasesRelation"
  has_many :suite_cases_relations_destination, :foreign_key => :case_destination, :dependent => :destroy,  :class_name=>"SuiteCasesRelation"

  acts_as_authorizable

  include SaveModelAccess

  validates_presence_of :user_id, :message => _("Must complete User Field")
  validates_presence_of :circuit_id, :message => _("Must complete Script Field")
  
  class SymbolAccessHash < Hash
	def [] (index)
		super(index.to_sym)
	end
	def []= (index, value)
		super(index.to_sym,value)
	end
  end


  def self.data_column_names( circuit )
    columns = circuit.circuit_case_columns.map(&:name)
    #order -> first default columns
    others_columns  = columns.select{|n| n !~ /^default_*/}
    default_columns = columns.select {|n| n =~ /^default_*/}
    default_columns + others_columns
  end
  

  def get_case_data( base_object = nil)
    aux = SymbolAccessHash.new
    self.case_data.each do |cd|
	aux[cd.column_name] = cd.data
    end
    # Return nil for undefined col
    columns = CaseTemplate.data_column_names(circuit)
    columns.each do |col|
        unless aux[col] then
           aux[col] = ""
       end
    end
     return aux
  end

  def add_case_data( data_attributes={} )
	self.case_data.each do |case_data|
		if data_attributes.include?(case_data.circuit_case_column.name.to_sym)
			case_data.data = data_attributes[case_data.circuit_case_column.name.to_sym] 
			case_data.save
			data_attributes.delete(case_data.circuit_case_column.name.to_sym)
		else
			ase_data.destroy
		end
	end
	data_attributes.each do |key, value|
	    circuit_case_column = CircuitCaseColumn.find( :first, :conditions => ["circuit_id = ? and name = ? ", self.circuit_id,  key.to_s] )
	    raise "invalid column '#{key}' for circuit '#{self.circuit.name}'"  unless circuit_case_column
	    case_data = self.case_data.new
	    case_data.circuit_case_column_id = circuit_case_column.id
	    case_data.data = value
	    case_data.save
       end

  end


   def update_case_data( data_attributes )
	 add_case_data(data_attributes)
   end


  def readonly
        begin
	   check_access
		return false
	rescue Exception => e
		return true
	end
	return true
  end


  def save
      check_access
      #If saved data without an defined script, and staying in "pending",
      # save it now
      if @post_add_case_data_attributes
	 super 
	 add_case_data(@post_add_case_data_attributes)
	 @post_case_data_attributes = nil
	 return true
      else
	 return super
      end
  end

  def last_execution(user_id=nil)
    #Add the model to avoid "undefined class/module" error
    Execution
    Circuit
    DataRecovery
    DataRecoveryName
    SuiteExecution
    
    last_execution = nil
    
    #Search the last execution id for logged user
    execution_id = Rails.cache.read "user_#{(user_id.nil? ? current_user.id : user_id)}_ct_#{self.id}"
 
    if execution_id == 'no'
      #case without executions
      return nil
    elsif execution_id
      cache_last_execution = Rails.cache.read "exec_#{execution_id}"
      if cache_last_execution.nil?
        last_execution = self.executions.find(:first,
                                            :conditions => ["user_id = ?", (user_id.nil? ? current_user.id : user_id)],
                                            :order => "updated_at desc",
                                            :limit => 1)
        #save in cache the last execution
        Rails.cache.write("exec_#{last_execution.id}",last_execution)
      end
    else
      last_execution = self.executions.find(:first,
                                            :conditions => ["user_id = ?", (user_id.nil? ? current_user.id : user_id)],
                                            :order => "updated_at desc",
                                            :limit => 1)
      if last_execution
        #Searching execution cache
        cache_last_execution = Rails.cache.read "exec_#{last_execution.id}"
        #save last case execution id in cache
        Rails.cache.write("user_#{(user_id.nil? ? current_user.id : user_id)}_ct_#{self.id}",last_execution.id)
      else
        #save last case execution id in cache
        Rails.cache.write("user_#{(user_id.nil? ? current_user.id : user_id)}_ct_#{self.id}","no")
      end
    end
    
    if cache_last_execution
       return cache_last_execution
    else
       return last_execution
    end    
  end
  

   def self.build_conditions(params)

   #Bulid conditions
      conditions        = Array.new
      conditions_names  = Array.new
      conditions_values = Array.new

      conditions_names << ' circuit_id = ? ' 
      conditions_values << params[:circuit_id]
      if  params[:case_templates] && params[:case_templates][:objective]
         conditions_names << ' objective like ? ' 
         conditions_values << '%' + params[:case_templates][:objective] + '%'
      end

      conditions << conditions_names.join('and')  
      conditions = conditions + conditions_values
      conditions
   end


end
