# == Schema Information
# Schema version: 20110630143837
#
# Table name: suites
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  description :text
#  project_id  :integer(4)
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
class Suite < ActiveRecord::Base
  # belongs_to :category

  has_many :schematics,  :dependent => :destroy
  has_many :circuits, :through => :schematics, :order => :position
  has_many :case_templates, :through => :schematics
  has_many :suite_executions,  :dependent => :destroy
  has_many :suite_fields_relations, :dependent => :delete_all
  has_many :suite_cases_relations,  :dependent => :delete_all
  has_many :suite_containers, :dependent => :destroy
  has_and_belongs_to_many :task_programs

  belongs_to :project
  named_scope :active, :conditions => { :deleted => false }
  named_scope :deleted, :conditions => { :deleted => true }

  validates_presence_of :name, :message => _("Enter a Name")
  validates_presence_of :description, :message => _("Enter a Description")
  validates_presence_of :project_id, :message => _("Enter a Project")

  after_save    :expire_cache
  after_destroy :expire_cache
  
  acts_as_authorizable

  include SaveModelAccess

  def active?
    !deleted
  end

  def self.new_suite(suite_params, suite_circuits)
	    @suite = Suite.new(suite_params)
	    @suite.circuits = Circuit.find(suite_circuits) if suite_circuits
      @suite
  end

  def soft_delete
    self.suite_fields_relations.clear
    self.suite_cases_relations.clear
    self.deleted = true
    self.save
  end

  #obtain col from every suite's script
  def circuits_data
      # hash format: [circuit_id =>{circuit_case_column1, circuit_case_column2, etc..}]
      suite_circuits_data = Hash.new
      columns_data        = Array.new
      self.circuits.to_a.each do |circuit|
        columns_data = circuit.circuit_case_columns
        suite_circuits_data[circuit.id] = columns_data
      end
      return suite_circuits_data
  end

  #delete suite case
  def delete_case(case_id)
    #delete suite case (Tabla Schamatics)
    case_template = CaseTemplate.find case_id
    self.case_templates.delete(case_template)
	  #Delete suite-case relations with cases from another suite
	  case_template_ids = self.case_templates.map(&:id)
	  array_relations_to_save = Array.new

	  self.suite_cases_relations.each do |suite_case_relation|
		   array_relations_to_save << suite_case_relation.id if case_template_ids.include?(suite_case_relation.case_origin) and case_template_ids.include?(suite_case_relation.case_destination)
	  end
	  self.suite_cases_relation_ids = array_relations_to_save
  end


  #schematics update (circuits and cases)
  def update_circuits(circuits_ids)

      if circuits_ids
           #get suite cases
           all_cases_suite =  self.case_templates.map(&:id)
           
           self.circuits = Circuit.find(circuits_ids)
           
           suite_cases_relations = Array.new
           self.suite_cases_relations.each do |suite_cases_relation|
              if circuits_ids.include?(suite_cases_relation.circuit_origin.to_i) and circuits_ids.include?(suite_cases_relation.circuit_destination.to_i)
                # leave the relationship in the suite if the cases are applicable
                suite_cases_relations << suite_cases_relation
              else
                #delete register
                suite_cases_relation.destroy
              end
           end
           
           self.suite_cases_relations = suite_cases_relations
           
           suite_fields_relations = Array.new
           self.suite_fields_relations.each do |suite_fields_relation|
              if circuits_ids.include?(suite_fields_relation.circuit_origin_id.to_i) and circuits_ids.include?(suite_fields_relation.circuit_destination_id.to_i)
                #leave the relationship in the suite if the cases are applicable
                suite_fields_relations << suite_fields_relation
              else
                #delete register
                suite_fields_relation.destroy
              end
           end
           self.suite_fields_relations = suite_fields_relations

           #schematic cases update
            #suite scripts get
             all_circuit_cases = Array.new
             self.circuits.each do |c|
               all_circuit_cases += c.case_templates.map(&:id)
             end
             #new case templates get
             self.case_templates = CaseTemplate.find( all_cases_suite &  all_circuit_cases )

      else
         self.errors.add(:scripts, _("Must add at least one Script to Suite"))
      end
      self
  end

 #Script relations update
  #replace existing relations
 def update_circuit_relations(c_origin, c_destination, new_relations)
    #delete all relations
    old_relations = self.suite_fields_relations.find(:all, :conditions => ["circuit_origin_id = ? and circuit_destination_id = ?", c_origin.id, c_destination.id])
    if !old_relations.nil?
      old_relations.each do |rr|
        rr.delete
        rr.save
      end
    end

    #add new relations
    if !new_relations.nil?
      #save, in suite_fields_relation, relations fields
        new_relations.each do |relation|
         SuiteFieldsRelation.create(:suite_id=>self.id,
                                    :circuit_origin_id=>c_origin.id,
                                    :circuit_destination_id=>c_destination.id,
                                    :field_origin=>relation[1]["origin"],
                                    :field_destination=>relation[1]["destination"])
        end
   #delete al reletions
   else
      #delete cases
      @suite_cases_relations = self.suite_cases_relations.find(:all, :conditions => ["circuit_origin = ? and circuit_destination = ?", c_origin.id, c_destination.id])
      @suite_cases_relations.each do |relation|
        relation.delete
        relation.save
      end
   end

 end

 #relations cases update
 #new_cases cant be nil
 #because is needed for relation3

 def update_cases_relations(ids_origin, ids_destination, new_cases)

    #delete all exist relations
    self.suite_cases_relations = self.suite_cases_relations.select { |suite_cases_relation|
    not ( ids_origin.include?(suite_cases_relation.case_origin.to_s) and ids_destination.include?(suite_cases_relation.case_destination.to_s) )
    }
    #new relation cases update
	    new_cases.split(";").each do |pair_cases|
	     case_origin = pair_cases.split(",")[0]
	     case_destination = pair_cases.split(",")[1]
	     SuiteCasesRelation.create(:suite_id=>self.id,
                                 :case_origin=>case_origin.to_i,
                                 :circuit_origin=> CaseTemplate.find(case_origin.to_i).circuit_id,
                                 :case_destination=>case_destination.to_i,
                                 :circuit_destination =>CaseTemplate.find(case_destination.to_i).circuit_id)
	   end
    
 end
 
  #import suites to selected project
  def copy_to_project(project_id, copy_cases)
    @project = Project.find project_id
    #import scripts to the project
    import_folder = _("Imported")
    @category = @project.categories.find_by_name(import_folder)
    
    if @category.nil?
	   @category = Category.new
	   @category.name = import_folder
	   @category.description = _("folder where you saved the script imported")
	   @category.parent_id = 0
	   @category.project_id = @project.id
	   @category.save
	end

    #copy scripts to my project
    par_circuit_ids = @category.import_circuits(@project, self.circuit_ids, 'off')
    	
    	
    #new suite generation
    @new_suite = Suite.new_suite(self.attributes,self.circuit_ids)
    @new_suite.project_id = project_id
    @new_suite.save
    
    # imported scripts asociation
    @new_circuits = Circuit.find par_circuit_ids.values
    @new_suite.circuits = @new_circuits
	@new_suite.save
	
    #copy the suite cases
    if copy_cases == 'on'
      par_case_template_ids = Hash.new
      self.case_templates.each do |case_template|
        @new_case_template = CaseTemplate.new(case_template.attributes)
        @new_case_template.circuit_id = par_circuit_ids[case_template.circuit_id]
        @new_case_template.save
        
        #Copy CaseDatum
        case_template.case_data.each do |case_datum|
          @new_case_data = CaseDatum.new(case_datum.attributes)
          @new_case_data.case_template_id = @new_case_template.id
          @new_case_data.circuit_case_column_id = @new_case_template.circuit.circuit_case_columns.find_by_name(case_datum.circuit_case_column.name).id
          @new_case_data.save
        end
        
        #save "viejo_case_template_id" => "nuevo_case_template_id"
        par_case_template_ids[case_template.id] = @new_case_template.id
      end    

      #Associate imported cases to the suite
      @new_case_templates = CaseTemplate.find par_case_template_ids.values
      @new_suite.case_templates = @new_case_templates
	  @new_suite.save
	  
	  #copy suite_cases_relations only if cases are copied
	  self.suite_cases_relations.each do |suite_case_relation|
	   @new_suite_cases_relation = SuiteCasesRelation.new(suite_case_relation.attributes)
	   @new_suite_cases_relation.suite_id = @new_suite.id
	   @new_suite_cases_relation.case_origin = par_case_template_ids[suite_case_relation.case_origin]
	   @new_suite_cases_relation.case_destination = par_case_template_ids[suite_case_relation.case_destination]
	   @new_suite_cases_relation.circuit_origin = par_circuit_ids[suite_case_relation.circuit_origin]
	   @new_suite_cases_relation.circuit_destination = par_circuit_ids[suite_case_relation.circuit_destination]
	   @new_suite_cases_relation.save
	  end
	end
	
	#copy suite_fields_relations
	self.suite_fields_relations.each do |suite_field_relation|
	   @new_suite_fields_relation = SuiteFieldsRelation.new(suite_field_relation.attributes)
	   @new_suite_fields_relation.suite_id = @new_suite.id
	   @new_suite_fields_relation.circuit_origin_id = par_circuit_ids[suite_field_relation.circuit_origin_id]
	   @new_suite_fields_relation.circuit_destination_id = par_circuit_ids[suite_field_relation.circuit_destination_id]
	   @new_suite_fields_relation.save
	end

  end

  def expire_cache
    Rails.cache.delete "suite_#{self.id}"
    #update project suites in cache
    Rails.cache.write("project_suites_#{self.project_id}", self.project.suites.active.map(&:id), :expires_in => CACHE_EXPIRE_PROYECT_SUITES)
    true
  end



#--------------------------------Special Structure build---------------------------------#

	#get script relations
  def get_circuits_relations
    	#relation scripts (hash format: script id -> [[parent],[chidren]] )
	    circuit_relations = Hash.new
    	self.circuits.each do |c|
	      relation = Array.new
	      circuits_children = self.suite_fields_relations.find(:all, :conditions => "circuit_origin_id = #{c.id}", :select => "circuit_destination_id").map{ |x| x.circuit_destination_id }
	      circuits_parents  = self.suite_fields_relations.find(:all, :conditions => "circuit_destination_id = #{c.id}", :select => "circuit_origin_id").map{ |x| x.circuit_origin_id }
	      #delete repetitions (unic)
        relation                =  [circuits_parents.uniq, circuits_children.uniq]
	      circuit_relations[c.id] = relation
	    end
      circuit_relations
  end


 #for 2 scripts:
 #hash format: { origin script + destination script => [[case1, case2], [,] ..] }
 def get_circuit_cases
	   circuits_cases= Hash.new
     self.suite_cases_relations.each do |suite_case|
	      case_pair = Array.new
	      #generate key
	      key_circuits = suite_case.circuit_origin.to_s + "_" + suite_case.circuit_destination.to_s
	      #generate pair
	      case_pair = [suite_case.case_origin.to_s , suite_case.case_destination.to_s]
	      #if key exist
	      if circuits_cases.key?(key_circuits)
		        #add case_pair to array
		        circuits_cases[key_circuits] << case_pair
	      else
		       #generate new key
		       #create array [[case1, case2], [,] ..]
	      	cases_pair = Array.new
		      cases_pair << case_pair
	      	circuits_cases[key_circuits] = cases_pair
        end
	    end
     circuits_cases
 end


#relation fields between two suite scripts
 def get_circuits_fields_relation
   #hash format: {origin script_destination script => [[ origin field, destination field], [,] ..]}
	 circuits_fields_relation = Hash.new
   self.suite_fields_relations.each do |f|
        #generate key
        key_circuits = f.circuit_origin_id.to_s   + "_" + f.circuit_destination_id.to_s
        #generate pair
        fields_pair = Array.new
        fields_pair = [f.field_origin, f.field_destination]
        #if key exist
        #add pair
        if  circuits_fields_relation.key?(key_circuits)
            circuits_fields_relation[key_circuits] <<  fields_pair
        #generate new key
        else
           #create array: [[ origin field, destination field], [,] ..]
           fields_relation = Array.new
           fields_pair = [f.field_origin, f.field_destination]
           fields_relation << fields_pair
           circuits_fields_relation[key_circuits] =  fields_relation
        end
     end
     circuits_fields_relation
 end


 def get_graph(circuits_fields_relation)
     require 'graphviz'
    #only for relation exists
    if !circuits_fields_relation.empty?
        g = GraphViz::new( "structs", "type" => "graph")
        g[:rankdir] = "LR" #Para vertical: TB

          g.node[:color]    = "#626894"
          g.node[:shape]    = "box"
          g.node[:penwidth] = "1"
          g.node[:fontname] = "sans-serif"
          g.node[:fontsize] = "8"
          g.node[:fillcolor]= "#DBE5E8"
          g.node[:fontcolor]= "#31576F"
          g.node[:margin]   = "0.05"


        #arrows
         g.edge[:color]    = "#626894"
         g.edge[:weight]   = "1"
         g.edge[:fontsize] = "9"
         g.edge[:fontcolor]= "#444444"
         g.edge[:fontname] = "sans-serif"
         g.edge[:dir]      = "forward"
         g.edge[:arrowsize]= "0.2"

       self.circuits.each do |c|
          name = (c.name.length >25)?c.name.slice(0..25) + "..." : c.name
          g.add_node(c.id.to_s).label = name
       end

       circuits_fields_relation.each do |circuits,fields|
         circuit1 = circuits.split('_')[0].to_s
         circuit2 = circuits.split('_')[1].to_s
         g.add_edge(circuit1, circuit2)
       end

      g.output( "output" => "png", :file => "#{RAILS_ROOT}/public/images/graphs/#{self.id}.png" )
      true
   else
      false
   end
 end

  #Search suite with pattern
  def self.get_all(pattern, project)
    pattern.strip! unless pattern.nil?
    if pattern.empty?
      #obtain project suites from cache
      suites=[]
      project.suites_cache.each do |identifier|
        suites << Suite.find(identifier)
      end
      result = suites
    else
      suites = Suite.active.project_id_equals(project.id)
      result = suites.name_like(pattern).to_a | suites.description_like(pattern).to_a
    end
    result.sort_by { |x| x.name.downcase }
  end
#--------------------------------------------------------------------------------------------#

  protected
   def self.find(*args)

      #One suite "1"
      if args.first.instance_of?(Fixnum) and args.length == 1
        Rails.cache.fetch("suite_#{args.first}", :expires_in => CACHE_EXPIRE_PROYECT_SUITES) { super(*args) }

      #Many suites "1,2,3..."
      elsif args.first.instance_of?(Array)
         suites = []
         args.first.each do |suite_id|
            suites << Rails.cache.fetch("suite_#{suite_id}", :expires_in => CACHE_EXPIRE_PROYECT_SUITES) { super(*args) }
         end
         suites

      #Super
      else
        super(*args)
      end

   end


end
