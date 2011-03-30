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
# Table name: circuits
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  category_id :integer(4)
#  source_code :text
#  user_id     :integer(4)
#

require "#{RAILS_ROOT}/lib/generator/processor"
require "#{RAILS_ROOT}/lib/generator/fake_selenium"
require "#{RAILS_ROOT}/lib/generator/selenium_data_collector"
require "#{RAILS_ROOT}/lib/generator/selenium_generate_circuit"
require 'spreadsheet/excel'
include Spreadsheet

class Circuit < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  has_many :case_templates, :dependent => :destroy
  has_many :schematics, :dependent => :destroy
  has_many :data_recovery_names, :dependent => :destroy
  has_many :suites, :through => :schematics

  has_many :suite_cases_relations_origin,      :foreign_key => :circuit_origin     , :dependent => :destroy,  :class_name=>"SuiteCasesRelation"
  has_many :suite_cases_relations_destination, :foreign_key => :circuit_destination, :dependent => :destroy,  :class_name=>"SuiteCasesRelation"

  has_many :suite_fields_relations_origin,      :foreign_key => :circuit_origin_id     , :dependent => :destroy,  :class_name=>"SuiteFieldsRelation"
  has_many :suite_fields_relations_destination, :foreign_key => :circuit_destination_id, :dependent => :destroy,  :class_name=>"SuiteFieldsRelation"

  has_many :circuit_case_columns,    :dependent => :destroy
  accepts_nested_attributes_for :circuit_case_columns
  has_many :circuit_access_registry, :dependent => :destroy
  has_many :executions, :dependent => :destroy
  
  validates_presence_of :user_id, :message => _("Must complete an Owner")
  validates_presence_of :name, :message => _("Must complete Name field")
  validates_presence_of :description, :message => _("Must complete Description Field")
  validates_presence_of :category_id, :message => _("Must complete a Parent Category")

  # indicate that the model is versioned
  begin
    # verify the existence of "versions" table
    queryverificacion = "select number, created_at, versioned_type, id, versioned_id, changes from versions limit 1"
    ActiveRecord::Base.connection.select_one(queryverificacion)
    versioned
    self.versioned_columns = ["name", "description", "source_code"]
    after_save :clean_versions
    rescue Exception => e
  end
  
  before_validation     :delete_carriage_return
  after_save            :update_user_last_edited_scripts
  acts_as_authorizable

  include SaveModelAccess

  #Calumn name Verify
  def case_column_names_valid?(column_names)
    valid = true
     #model CircuitCaseColumn Validation
    column_names.each do |column_name|
      c = CircuitCaseColumn.new(:name => column_name, :circuit_id =>0)
      if !c.valid?
        #Name invalid => add error to Script
        c.errors.to_a.each do |e|
          errors.add_to_base(column_name + ": " + e[1])
        end
        valid = false
      end
    end
    valid
  end 


  #data script is obtained in a hash with {name=>code} format
  def data_recoveries_hash
	   aux = Hash.new
	   self.data_recovery_names.each do |d|
		   aux[d.name.to_sym] = d.code
	   end
	   return aux
  end
  
  #VERSION_MAX_FOR_CIRCUIT --> version script number max allowed checker
  def clean_versions
    VersionExtras.clean_versions("circuit")
    if self.versions.count > VERSION_MAX_FOR_CIRCUIT
      self.versions.delete(self.versions.first)
    end
  end

  def save
	  check_access
	  return super
  end

  #Add col to script
  def add_case_columns( new_columns, default_value=nil )
    if new_columns
      new_columns.each do |column_name|
        ccc = self.circuit_case_columns.new
        ccc.name = column_name
        ccc.save
        self.add_value_to_all_cases(ccc.id,default_value) if default_value
      end
    end
  end
  
  #Add a default value in a specified column in all cases
  def add_value_to_all_cases(column_id, value)
    self.case_templates.each do |case_template|
      case_data = case_template.case_data.new
      case_data.circuit_case_column_id = column_id
      case_data.data = value
      case_data.save
    end
  end
  
  #Modify col to script
  def modify_case_columns(column, new_name)
    ccc = self.circuit_case_columns.find_by_name column
    ccc.name = new_name
    ccc.save
  end

  #col Delete
  def delete_case_columns( column )
    circuit_case_column = self.circuit_case_columns.find_by_name(column)

    #SuiteFieldsRelation dependencies delete
      suite_fields_relations =  self.suite_fields_relations_origin.find_all_by_field_origin(column) +
                                self.suite_fields_relations_destination.find_all_by_field_destination(column)
      suite_fields_relations.each do |sfr|
        sfr.destroy
      end
    #DataRecoveryName dependencies delete
      data_recovery_names = self.data_recovery_names.find_all_by_code( 'data[:' + column + ']')
      data_recovery_names.each do |dr|
        dr.destroy
      end
    #col destroy
    circuit_case_column.destroy

  end


  #first case for an cacique script
  def add_first_data_set( new_data )
     @case_template = CaseTemplate.new
     @case_template.objective = _("Enter a Goal")
     @case_template.user_id    = current_user.id
     @case_template.circuit_id = self.id
     @case_template.save

     #edit permission over new case template
     current_user.has_role("editor", @case_template, :nocheck)

     #add col
     @case_template.add_case_data(new_data)
     @case_template.save
  end

  #data from selenium recorder
  def self.selenium_data_collector( params )
  	dc = SeleniumDataCollector.new
	  file = params[:name]
	  processor = Processor.new( dc )
	  processor.process_test_case( file )
	  return dc.data.to_a
  end

  #data script generator
  def self.selenium_generate_circuit( params )
    circuit = params[:circuit]
    path_name = params[:name]
	  circuit.source_code = SeleniumGenerateCircuit.generate do |dc|
		  dc.subs_data.add_selenium_driver_init( path_name )
		  dc.subs_data.subs_hash = params[:data]
	  	processor = Processor.new( dc )
		  processor.process_test_case( path_name )
	  end
	circuit.save
  end

  #find scrip by name
  #return nill for an scrip outside the prject
  def search_circuit(name_)
	  return self if self.name  == name_
	  if category
		  return category.search_circuit(name_)
	  end
  end
  
  #data pool xls generator
  def export_cases
        
    @exclude_columns_template = ["user_id","circuit_id", "updated_at"]
    @exclude_columns_data = ["case_template_id","updated_at","created_at", "id"]
     
    workbook = Excel.new("#{RAILS_ROOT}/public/excels/casos_de_#{self.id}.xls")
    hoja_cases = workbook.add_worksheet("Casos")
    columna = 0

    #TITLES
    case_template_columns = CaseTemplate.column_names
    case_template_columns.each do |column_name|
      if !@exclude_columns_template.include?(column_name)
        hoja_cases.write(0,columna,column_name)
        columna += 1
      end
    end

    case_data_columns = CaseTemplate.data_column_names(self)
    case_data_columns.each do |column_name|
      if !@exclude_columns_data.include?(column_name)
        hoja_cases.write(0,columna,column_name)
        columna += 1
      end
    end
  #Last Execution
  hoja_cases.write(0,columna,"Last execution")

   #DATA 
   @cases_templates = CaseTemplate.find(:all, :conditions => ["circuit_id = ?", self.id], :include => :case_data)
    fila = 1
    @cases_templates.each do |case_template|
      columna_aux = 0
      case_template_columns.each do |column_template|
        if !@exclude_columns_template.include?(column_template)
          if column_template == "created_at"
            hoja_cases.write(fila,columna_aux,case_template.send(column_template).to_s(:short).split("-")[1])
          else
            hoja_cases.write(fila,columna_aux,case_template.send(column_template))
          end
          columna_aux += 1
        end
      end

      case_data_columns.each do |column_data|
        if !@exclude_columns_data.include?(column_data)
          hoja_cases.write(fila,columna_aux,case_template.get_case_data[column_data.to_sym])
          columna_aux += 1
        end
      end
      #Last Execution
      status_execution = case_template.last_execution
      hoja_cases.write(fila,columna_aux, (status_execution.nil?)? "" :  status_execution.s_status)

      fila += 1
    end

    workbook.close
    true
  end

 #Copy an script with, or without, data pool
 def copy(with_cases)
    circuit_new = Circuit.create(:name=>self.name + _('-copy'),:description=>self.description, :category_id=> self.category_id, :source_code=>self.source_code, :user_id => current_user.id )
    #new scrip fields
    circuit_new.add_case_columns( self.circuit_case_columns.map(&:name) )
    circuit_new.save
    
    #add user id to first version
    last_version = circuit_new.versions.last
    last_version.user_id = current_user.id
    last_version.save
    
    #Data recoveries
    self.data_recovery_names.each do |data_recovery|
      DataRecoveryName.create(:circuit_id=>circuit_new.id, :name=>data_recovery.name, :code=>data_recovery.code)
    end
   #if select this, data pool is copied
     #case_templates and case_data copy
    if with_cases != "false"
		  self.case_templates.each do |case_template|
        case_template_new = CaseTemplate.create(:circuit_id=>circuit_new.id,:objective=>case_template.objective,:priority=>case_template.priority, :user_id=>current_user.id  )
			   case_template.case_data.each do |case_data|
            CaseDatum.create(:case_template_id=>case_template_new.id, :circuit_case_column_id=>case_data.circuit_case_column_id,:data=>case_data.data)
			   end
		  end
    end
 end


 def import( fileUpload, name, user_id  )

    upload = Hash.new
    #file import
    upload[:fileUpload] = fileUpload.read
    #file imported name
    upload[:name] = name
    csvname = "#{RAILS_ROOT}/public/casos.csv"

    if DataFile.save_import( upload )

      primera = true
      @columns_template = CaseTemplate.column_names
      @columns_data = CaseTemplate.data_column_names( self )

      #xls to csv converter
      raise "No se puede llamar xls2csv, posiblemente no este en el sistema" unless  system("xls2csv #{RAILS_ROOT}/public/casos.xls > #{csvname}" )

      File.open(csvname, "r") do |f|
        f.readlines.each do |record|

          record.gsub!("\n","")
          record.gsub!("\"","")

          if primera
            @columns_names = record.split(/[,;]/)
            primera = false
          else
            columns = record.split(/[,;]/)

            if columns.size > 1 then
              i = 0
              attributes_template =  Hash.new
              @columns_template.each{ |c| attributes_template[c] = "" }
              attributes_data = Hash.new
              @columns_data.each{ |c| attributes_data[c] = "" }
              columns.each do |column|
                if @columns_template.include?(@columns_names[i])
                  attributes_template[@columns_names[i]] = column
                elsif @columns_data.include?(@columns_names[i])
                  attributes_data[@columns_names[i]] = column
                end
                i += 1
              end
              attributes_template["circuit_id"] = self.id
              attributes_template["user_id"]  = user_id
              attributes_template["created_at"] = nil
              case_template = CaseTemplate.create(attributes_template)
              case_template.save
 
              if case_template.objective != "\f"
                case_template.add_case_data(attributes_data)
                case_template.save
              end
            end

          end
        end
      end
      return true
    else
      return false
    end
  end

 #Script columns obtain for create a select with this values
 def get_columns_names(exclude_columns = [])
      columns_names = Array.new
      columns_names.concat(CaseTemplate.data_column_names(self) )
      exclude_columns.each do |column_exclude|
        columns_names.delete(column_exclude)
      end
      columns_names
 end

 def self.get_all(pattern)
   result=Array.new
   result= Circuit.name_like(pattern).to_a |  Circuit.description_like(pattern).to_a
   result
 end
 
 #search last script execution
 def last_execution_self
   Execution
  #search first in cache
  execution_id = Rails.cache.read("user_#{current_user.id}_circuit_#{self.id}_self")
  if execution_id
    execution = Rails.cache.read("exec_#{execution_id}")
    if !execution
      #search in db if not cached
      execution = Execution.find execution_id
    end
  else
    execution = self.executions.find( :first,
                                      :conditions => "user_id = #{current_user.id} and case_template_id = 0",
                                      :order => "updated_at desc",
                                      :limit => 1)
  end
  
  execution
  
 end
 
 #Circuit checks if his source code has no syntax error
 def check_syntax
   Circuit.syntax_checker(self.source_code)
 end
 
 #This class method validates ruby syntax, this method get the code and return a hash within two values, 
 #:status => true if the code has no errors, otherwise it will return false
 #:message=> this value will storage all warnings and errors messages 
 def self.syntax_checker(code)
   file_name="#{RAILS_ROOT}/tmp/script_#{self.id}.rb"
   File.delete(file_name) if File.exists?(file_name)
   File.open(file_name, 'w') {|f| f.write(code) }
   aux=`ruby -c #{file_name} 2>&1`
   File.delete(file_name)
   status=aux.include?("Syntax OK\n")

   #Se separan los errores de los warnings
   aux2 = aux.split("#{file_name}:")
   errors   = Array.new
   warnings = Array.new
   #S e quita el Status Ok del array di desta OK
   aux2[aux2.length - 1].gsub!("\nSyntax OK\n","") if status
   #Se quita el primer elemento que contenia solo el nombre del archivo
   result = aux2[1..(aux2.length - 1)]
   result.each do |r|
     r.include?(" warning:")? warnings << r  : errors   << r
   end

   {:status=>status,:errors=>errors, :warnings=>warnings}
 end

  
  def self.circuits_with_column(new_column)
         circuits = Array.new
         #Add the column of context_configuration.field_default
        columns = CircuitCaseColumn.all
        columns.each do |column|
             circuits << column.circuit if column.name == new_column
        end
        circuits
  end
  
  def update_user_last_edited_scripts      
      #Update the last script edited of project
      if current_user
        user_scrips_edit = Rails.cache.read("circuit_edit_#{current_user.id}")
        user_scrips_edit = {} if user_scrips_edit.nil?
        user_scrips_edit[self.category.project_id] = self.id
        Rails.cache.write("circuit_edit_#{current_user.id}",user_scrips_edit)   
      end   
 end

 def self.expires_cache_circuit(circuit_id, project_id)
      if current_user
        user_scrips_edit  = Rails.cache.read("circuit_edit_#{current_user.id}")
        if user_scrips_edit
          #Deletes all pairs where the script is involved
          update_user_scrips_edit = user_scrips_edit.delete_if {|key, value| key == project_id and value == circuit_id } 
          Rails.cache.write("circuit_edit_#{current_user.id}",update_user_scrips_edit)  
        end
      end
 end


  def save_source_code(originalcontent, content, commit_message)
    
     actual_version = self.versions.last

     #changes verify
     original_source_code =  Digest::SHA1.hexdigest(self.source_code)

     if original_source_code != originalcontent
       return self.circuit_access_registry.last
     end

	 self.source_code = CGI.unescapeHTML( content )
     self.save

     last_version = self.versions.last
     if actual_version
        if actual_version.number != last_version.number
         last_version.message = (commit_message || "")
        end
     else
         last_version.message = (commit_message || "Initial commit")
     end
     last_version.user_id = current_user.id
     last_version.save
    
     return true
     
  end












private
  #Delete carriage return to resguard views tree
  def delete_carriage_return
     self.description.gsub!("\r\n","") unless self.description.nil?
  end

  def delete
    Version.destroy(self.versions.map(&:id))
    super delete
  end

end
