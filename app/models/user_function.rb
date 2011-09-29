# == Schema Information
# Schema version: 20110630143837
#
# Table name: user_functions
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  project_id  :integer(4)
#  name        :string(255)
#  description :text
#  cant_args   :integer(4)      default(0)
#  source_code :text
#  created_at  :datetime
#  updated_at  :datetime
#  example     :text
#  hide        :boolean(1)
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
class UserFunction < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  validates_presence_of :user_id, :message => _("Must complete an Owner")
  validates_presence_of :name, :message => _("Must complete Name field")
  validates_format_of   :name, :with => /^[a-z](_?[a-zA-Z0-9]+)*_?$/, :message => _("Should start with lowercase and only contain letters, numbers or underscore")
  validates_presence_of :description, :message => _("Must complete Description Field")
  validates_presence_of :source_code, :message => _("Must complete Code Field")
  validates_length_of :name, :maximum=> 50, :message => _("The Name must be a maximum of 50 characters")
  validates_presence_of :example, :message => _("Must complete example of how to use the function")
#  validates_length_of :description, :minimum => 20, :too_short => "Se debe ingresar una descripcion, que sea representativa de la funcion"

  validate :repeated_name
  
  # indicate that the model is versioned
  begin
    # verify the existence of "versions" table
    queryverificacion = "select number, created_at, versioned_type, id, versioned_id, changes from versions limit 1"
    ActiveRecord::Base.connection.select_one(queryverificacion)
    versioned
    self.versioned_columns = ["name", "source_code"]
    after_save :clean_versions
    rescue Exception => e
  end
  
  after_create :add_function_to_hash
  after_destroy :delete_from_cache
  after_save :add_user_in_last_version
  before_save :update_cache
  before_update :control_edit_name
  before_destroy :can_destroy?
  
  def repeated_name
      #function names verifier
      #verifies that there is no function with the same name in projects and generics
      if self.project_id == 0
        all_with_my_name = UserFunction.find_all_by_name self.name
        error = ""
        all_with_my_name.each do |function|
          if function.id != self.id
            if function.project_id == 0
              error += "Generico, \n"
            else
              error += function.project.name + ", \n"
            end
          end 
        end
        errors.add_to_base(_("Already Exist a function with that name:\n") + error) if !error.empty?
      else
        my_functions = UserFunction.find_all_by_project_id self.project_id
        my_functions.delete(self) if my_functions.include?(self)
        generic_functions = UserFunction.find_all_by_project_id 0
        generic_functions.delete(self) if generic_functions.include?(self) 
        errors.add_to_base(_("Already Exist a function with that name in this project")) if !my_functions.nil? and my_functions.map(&:name).include?(self.name)
        errors.add_to_base(_("Already Exist a Generic function with that name")) if generic_functions.map(&:name).include?(self.name)
      end

  end
  
  def generate_source_code(source_code, name, args)
    #"def functions" and "argument list" generator
    new_source_code = "def new_object." + name.strip + "("
    arguments = args.join(",")
    new_source_code += arguments
    new_source_code += ");"
    
    #add function codes
    new_source_code += source_code 
    
    #add "end" to function
    new_source_code += "\n end;"
    new_source_code
  
  end
  
  #search all functions names
  def self.hash_to_load_cache
    hash_functions = Hash.new
    return UserFunction.all.map(&:name)
  end
  
  #add function to functions hash
  def add_function_to_hash
    #save functions hash in cache
    Rails.cache.write("functions",UserFunction.hash_to_load_cache)
  end
  
  def delete_from_cache
    Rails.cache.delete "function_#{self.name}"
    #save functions hash in cache without deleted functions
    Rails.cache.write("functions",UserFunction.hash_to_load_cache)
  end
  
  def update_cache 
    functions = Rails.cache.read "functions"
    old_name  = self.name
    #Change name
    if self.changes.include?('name')
      old_name = self.changes['name'][0]
      Rails.cache.delete("functions") if old_name
    end
      Rails.cache.delete "function_#{old_name}"
    true 
  end
  
  def can_destroy?
    if self.name == "initialize_run_script" or self.name == "finalize_run_script" or self.name == "error_run_script"
      errors.add_to_base(_("You can not delete function ")+"#{self.name}"+_(", because it would affect the running of scripts"))
      return false
    end
    true
  end
  
  def control_edit_name
    if self.changes.include?('name')
      if self.changes['name'][0] == "initialize_run_script" or self.changes['name'][0] == "finalize_run_script"
        errors.add_to_base(_("You can not edit function Name ")+"#{self.changes['name'][0]}\n")
        return false
      end
    end
    return true
  end
  
  
  def show_source_code 
    source_code = ""
    #DEF and END delete
    begin
      def_code = self.source_code.split(";")[0]
      source_code = self.source_code.gsub(def_code+";","")
    rescue; end

    source_code.gsub!(/end\;$/,"")
    source_code
  end
  
  def show_arguments
    arguments = []
    begin
      def_code = self.source_code.split(";")[0]
      aux = def_code.split("(")
      if !aux[1].nil?
        aux[1][-1] = ""
        arguments = aux[1].split(",")
      end
    rescue;end
    
    arguments
  end
  
  #Looking for possible projects to move the function
  #Return the form [[name, id],[name2, id2]]
  def find_projects_to_move(user)
    projects_to_move = []
    
    if user.has_role?("root")
      projects = Project.all
    else
      projects = user.projects.dup
    end
    
    projects.delete(self.project)
    
    projects_to_move = projects.sort_by { |x| x.name.downcase }.collect{ |p| [p.name,p.id] }
    
    projects_to_move
  end
  
  def move_project(project_id)
    if self.name == "initialize_run_script" or self.name == "finalize_run_script" or self.name == "error_run_script"
      errors.add_to_base(_("You can not delete function ")+"#{self.name}"+_(", because it would affect the running of scripts"))
      return false
    end    
    self.project_id = project_id
    self.save
  end

  def self.get_user_functions_with_filters(projects,params)  
   #Bulid conditions
    conditions        = Array.new
    conditions_values = Array.new
    conditions_names  = Array.new    
 
    if !params[:visibility].nil?  and  !params[:logic].nil?
	    conditions_names  <<  " ( project_id in (?) #{params[:logic]} visibility = ? ) "
	    conditions_values <<  projects.collect{|x| x.to_i}#Ids string to integer
	    conditions_values <<  params[:visibility]
    elsif !params[:visibility].nil?
 	    conditions_names  <<  "  visibility = ?  "
	    conditions_values <<  params[:visibility]  
    elsif !projects.empty?
	    conditions_names  <<  " project_id in (?)  "
	    conditions_values <<  projects.collect{|x| x.to_i}#Ids string to integer
    end

    if params[:text] and !params[:text].empty?
        conditions_names  <<  " ( name like ? or description like ? ) "
        conditions_values <<  '%' + params[:text] + '%'
        conditions_values <<  '%' + params[:text] + '%'
    end

    if  params[:user_id] and !params[:user_id].empty?
        conditions_names  <<  " user_id = ?"
        conditions_values <<  params[:user_id]
    end
    conditions << conditions_names.join("and")  
    conditions = conditions + conditions_values 

    search     = UserFunction.find(:all, :conditions=>conditions, :order=> "name ASC")
    return search  
  end
    
  
  #VERSION_MAX_FOR_FUNCTION --> version function number max allowed checker
  def clean_versions
    VersionExtras.clean_versions("user_function")
    if self.versions.count > VERSION_MAX_FOR_FUNCTION
      self.versions.delete(self.versions.first)
    end
  end
  
  def add_user_in_last_version
    version = self.versions.last
    #If the latest version already contains "user_id"means that no changes 
    #were made in the code of the function
    if version.user_id.nil?
      if current_user
        version.user_id = current_user.id
      else
        version.user_id = self.user_id
      end
      version.save
    end
    true
  end
  
  
  def find_version(version)
    case version
      when 'max'
        return self.versions.map(&:number).select{ |n| n < self.version }.max
      when 'min'
        return self.versions.map(&:number).select{ |n| n > self.version }.min
    end
  end
  
  #Delete all empty parameters
  def self.prepare_args(args)
    arguments = []
    if !args.nil?
      args.delete_if{|k,v| v== ""}
      args.keys.map{|x|x.to_i}.sort.each do |key|
          arguments << args[key.to_s]
      end
    end
    
    arguments
  end
  
  def hide?
    if hide
      if current_user
        return false if current_user.has_role?("root")
        return false if self.user_id == current_user.id
      end
      return true
    end
      
    return false      

  end
  
end
