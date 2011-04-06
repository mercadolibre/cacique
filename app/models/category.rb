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
# Table name: categories
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :string(255)
#  parent_id   :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#  project_id  :integer(4)
#

class Category < ActiveRecord::Base
  acts_as_tree
  has_many :circuits,    :dependent => :destroy

  belongs_to :project

  validates_presence_of :name, :message => _("Must enter a Name")
  validates_presence_of :description, :message => _("Must enter a Description")
  validates_presence_of :project_id, :message => _("Must specify a Project to Category ")
  validates_presence_of :parent_id, :message => _("Must specify Parent Category")

  acts_as_authorizable

  before_validation :delete_carriage_return

  after_save :expire_cached_categories
  after_destroy :expire_cached_categories

 include SaveModelAccess


  def indirect_project
    if self.project
      self.project
    else

      begin

        parent_category = nil
        parent_category = Category.find( self.parent_id ) unless self.parent_id == 0

	    if parent_category
          parent_category.indirect_project
	    else
	      nil
	    end
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end

  end


  def search_circuit(name_)

    circuits = self.circuits.find(:all, :conditions => [ "name = ?", name_ ] )
    if circuits then
      if circuits.size > 1 then
        raise "Search by Script name is ambiguous"+" #{circuits.map{|x| x.description}.join(", ") } "
      end

      if circuits.size == 1 then
        return circuits.first
      end
    end

    proj = self.indirect_project
    if proj then
      return proj.search_circuit(name_)
    end

    nil
  end

  #delete carriage return to avoid tree view errors
  def delete_carriage_return
     self.description.gsub!("\r\n","") unless self.description.nil?
  end

  def resolve_project
    self.project = self.indirect_project
  end
  #return TRUE if categorie is empty
  def can_delete?
    can_delete = false
    can_delete = true if self.circuits.size == 0 and self.children.size == 0

    can_delete
  end


  #copy selected script to an specific category. If nothing, creates a "draft"
  #category. Can be only a "draft" for project.
  def import_circuits(project, circuits_ids, copiar_casos)

    #variable to save "viejo_circuit_id" => "nuevo_circuit_id"
    new_circuits_ids = Hash.new

    # to add an script in an specific category I must have edit permissions
	  if current_user.has_role?("editor", project)

	   circuits_ids.each do |circuit|
	      circuit_import = Circuit.find circuit.to_i

	      #new script generation
          circuit_new = self.circuits.new
          circuit_new.name = circuit_import.name + _("-copy")
	      circuit_new.description = circuit_import.description
	      circuit_new.category_id = self.id
	      circuit_new.user_id = current_user.id
          circuit_new.source_code = circuit_import.source_code
	      circuit_new.save
	      
	      #save all new ids from copied scripts
	      new_circuits_ids[circuit_import.id] =  circuit_new.id

	       #Data pool col name generation
	       circuit_import.circuit_case_columns.each do |circuit_case_column|
	         circuit_case_column_new = circuit_new.circuit_case_columns.new
	         circuit_case_column_new.name = circuit_case_column.name
	         circuit_case_column_new.circuit_id = circuit_new.id
	         circuit_case_column_new.save
	       end

        #data recovery name generation
	       circuit_import.data_recovery_names.each do |data_recovery_name|
	         data_recovery_name_new = circuit_new.data_recovery_names.new
	         data_recovery_name_new.name = data_recovery_name.name
           data_recovery_name_new.code = data_recovery_name.code
	         data_recovery_name_new.circuit_id = circuit_new.id
	         data_recovery_name_new.save
	       end

	      #add maker to first version
          last_version = circuit_new.versions.last
          last_version.user_id = current_user.id
          last_version.save


        if copiar_casos == 'on'
		    #case_templates and case_data copy
		    circuit_import.case_templates.each do |case_template|
		      case_template_new = circuit_new.case_templates.new
		      case_template_new.objective = case_template.objective
		      case_template_new.priority = case_template.priority
		      case_template_new.circuit_id = circuit_new.id
              case_template_new.user_id    = current_user.id
		      case_template_new.save

		      case_template.case_data.each do |case_data|
		        case_data_new = case_template_new.case_data.new
		        case_data_new.circuit_case_column_id = case_data.circuit_case_column_id
		        case_data_new.data = case_data.data
		        case_data_new.save
		      end
	       end
       end
	 end
   end

  #return circuits_ids
  new_circuits_ids

  end

  #get col names from scripts
  def get_columns_names(exclude_columns=[])
    columns = []
    #Scripts dentro de la categoría
    self.circuits.each do |circuit|
      columns += CaseTemplate.data_column_names( circuit )
    end
    #exclude_columns
    columns = columns.map(&:downcase).sort.uniq
    exclude_columns.each do |column_exclude|
      columns.delete(column_exclude)
    end
    columns
  end
  
  def save
    resolve_project
    super
  end
  
  
  # Project.all_cached_categories expire cache
  def expire_cached_categories
    Rails.cache.delete "project_categories_#{self.project_id}" 
  end
end
