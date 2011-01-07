class SuitesController < ApplicationController
  before_filter :load_categories, :only => [:new, :edit, :create]

  def index
    handle_invalid_action(ActiveRecord::RecordNotFound ) do
      @project = Project.find params[:project_id]
      permit "enumerator_of_suites of :project" do
        @suites = Suite.get_all(params[:search].to_s,@project)
        (!params[:search].nil?)? @param_search = params[:search] : @param_search = ""
  	    @suites_pag = @suites.paginate :page => params[:page], :per_page => 15
  	  end
    end
  end

  def new
    permit "creator_of_suites of :project" do
      @suite = Suite.new
    end
  end

  def show
    @suite = Suite.find(params[:id], :include => {:schematics => [:circuit, :case_template]})
    permit "viewer of :suite" do
	    @circuit_names = Hash.new
	    @circuit_relations = Hash.new
	    @circuits_cases= Hash.new
	    @circuits_fields_relation = Hash.new
      #Scripts Name
      #Hash format: (Script ID -> Script Name)
      @suite.circuits.each do |c|
	       @circuit_names[c.id] = c.name
	    end
	    #Scripts Relations
	    #Hash format: Script id -> [ [origin], [destiny]])
      @circuit_relations = @suite.get_circuits_relations
	    #CASES
	    #For 2 Scripts:
	    #Hash format:  { Irigin Script + Destiny Script => [ [ case1, case2], [,] ..] }
	    @circuits_cases = @suite.get_circuit_cases
	    #related Fields between 2 Scripts
	    #(format: origin script - destiny Srcript => [ [ origin field, destiny field], [,] ..] )
      @circuits_fields_relation = @suite.get_circuits_fields_relation
      #Suite Graph
      @suite.get_graph(@circuits_fields_relation)
       render :partial => "suite_show"
   end
  end

  def create
    permit "creator_of_suites of :project" do
       params[:suite][:project_id]=params[:project_id]
	     @suite = Suite.new_suite(params[:suite],  params[:circuits_ids])
	      if @suite.save
	        redirect_to '/suites/' + @suite.id.to_s + '/edit'

        else
	        render :action => 'new'
	      end
     end
  end

  #May or not receive update errors
  def edit(suite_update =nil)

     #May or not receive update errors
     if suite_update.nil?
	   @suite = Suite.find(params[:id], :include => {:schematics => [:circuit, :case_template]})
    else
       @suite = suite_update
     end

    permit "editor of :suite" do
	    session[:suite_id] = params[:id] # Saves the suite id, in the session, for updating the schematic relation in the sort action.
	    @circuits   = @suite.circuits
	    @total_tabs = @circuits.length

	    @circuits_names = Array.new
	    @circuits_ids   = Array.new
	    @circuits.each do |circuit|
	       @circuits_ids   << circuit.id
	       @circuits_names << circuit.name

	    end
      @cell_selects      = ContextConfiguration.build_select_data #Build the selects for edit cell
    end

  end

  def edit_cases
    @suite = Suite.find params[:id]
    @circuit = Circuit.find params[:circuit_id]
    @case_templates = @circuit.case_templates    
    @columns_data      = CaseTemplate.data_column_names( @circuit )
    @columns_template  = CaseTemplate.column_names
    @exclude_show      = [ :circuit_id, :user_id, :updated_at, :case_template_id]
    @exclude_show_data = [:id, :case_template_id, :updated_at, :created_at]
    @cell_selects      = ContextConfiguration.build_select_data #Build the selects for edit cell
    render :partial => "suite_cases", :locals => {:exclude_show => @exclude_show, :exclude_show_data => @exclude_show_data, :suite => @suite, :circuit => @circuit, :case_templates => @case_templates, :columns_data => @columns_data, :columns_template => @columns_template}
  end

  def delete
    @suite = Suite.find params[:id]
    permit "editor of :suite" do
      @suite.destroy
      redirect_to '/suites/'
    end
  end
  
  #Name and description update
  def update
    @suite = Suite.find params[:id]
    @suite.update_attributes(params[:suite])
    @editmsg = "OK"
    render :partial => "suite_information", :locals => { :suite => @suite, :msg => @editmsg }
  end
  
  #Suits Script Update
  def update_circuit
    @suite = Suite.find params[:id]
    @circuit_ids = @suite.circuit_ids
    if params[:circuit_id]
      if @circuit_ids.include?(params[:circuit_id].to_i)
        @circuit_ids.delete(params[:circuit_id].to_i)
      else
        @circuit_ids << params[:circuit_id].to_i
      end
      @suite.update_circuits(@circuit_ids)
    end
    
    render :partial => "circuits", :locals => {:suite_id => @suite.id, :circuits => @suite.circuits, :case_templates => @suite.case_templates}
  end
  
  #script order refresh
  def update_circuits_order
    @suite = Suite.find params[:id]
    @circuits = @suite.circuits
    
    render :partial => "circuits_order", :locals => {:circuits => @circuits}
  end

  # Updates the position of the circuits on the suite
  def sort
    @suite = Suite.find session[:suite_id]
       params[:circuits].each_with_index do |id, index|
       Schematic.update_all(['position=?', index+1],['circuit_id=? AND suite_id=?', id, @suite])
    end
    render :nothing => true
  end

  # Renders the fields in the edit form to update the cases related to the suite.
  def append_cases
    @suite = Suite.find params[:suite_id]
	  permit "editor of :suite" do
	    @circuit = Circuit.find params[:id]
	    @case_templates = CaseTemplate.paginate_all_by_circuit_id params[:id], :page => params[:page], :per_page => 6,:include => :circuit
	    render :partial => "append_cases", :layout => false, :locals => {:circuit => @circuit, :suite => @suite, :case_templates => @case_templates}
	  end
  end

  #add cases to suite
  def add_suite_case
    @suite = Suite.find params[:suite_id], :include => {:schematics => :case_template}
	  permit "editor of :suite" do
	    @suite.case_templates  << CaseTemplate.find(params[:case_id])
	    @suite.save
	    redirect_to '/suites'
	  end
  end

  # remove cases from suite
  def delete_suite_case
    @suite = Suite.find params[:suite_id], :include => {:schematics => :case_template}
    permit "editor of :suite" do
      @suite.delete_case(params[:case_id])
      @suite.save
      redirect_to '/suites'
    end
  end

  def relations1
    @names = Array.new
    @suite = Suite.find params[:id]
	  permit "editor of :suite" do
	    @circuits = @suite.circuits
      @circuit_id_from_name = Hash.new
	    @circuits.each do |c|
	      @names <<  c.name
        @circuit_id_from_name[c.name] = c.id
		  end
	  end
  end

  def relations2
   @suite = Suite.find params[:id]
   permit "editor of :suite" do
	   @circuits = @suite.circuits

	   #get selected scripts Id
	   @circuit_1 = Circuit.find params[:circuit_1]
	   @circuit_2 = Circuit.find params[:circuit_2]

	   #get Script data set
	   @columns_template = CaseTemplate.data_column_names( @circuit_1 )
	   @columns_data_1 = @circuit_1.data_recovery_names.map{|x| x.name } + CaseTemplate.data_column_names( @circuit_1 )

	   @columns_template = CaseTemplate.data_column_names( @circuit_2 )
	   @columns_data_2 = CaseTemplate.data_column_names( @circuit_2 )

     #Columns that should not be displayed
	   @exclude_show = [:id, :case_template_id, :updated_at, :created_at]

	   #obtain saved relations
	    @fields_relation_saved = Hash.new
	    @relation_saved     = SuiteFieldsRelation.find(:all, :conditions => "suite_id= #{@suite.id} AND circuit_origin_id = #{@circuit_1.id} AND circuit_destination_id = #{@circuit_2.id}")

	    @relation_saved.each do |c|
	       @fields_relation_saved[c.field_origin] = c.field_destination
	    end
    end
  end

  def relations3
    @circuit_origin = Circuit.find(params[:circuit_1])
  	@circuit_destination = Circuit.find(params[:circuit_2])

	  @suite = Suite.find params[:id]
	  permit "editor of :suite" do
      #relations refresh
      @suite.update_circuit_relations(@circuit_origin, @circuit_destination, params[:relations])
      redirect_to "/suites/relations1/#{ @suite.id}" if params[:relations].nil?
     	@casos_origin = @suite.case_templates.select{ |c| c.circuit_id == @circuit_origin.id}
	    @casos_destination = @suite.case_templates.select{ |c| c.circuit_id == @circuit_destination.id}
      @suite_cases_relations = @suite.suite_cases_relations.find(:all, :conditions => ["circuit_origin = ? and circuit_destination = ?", @circuit_origin.id, @circuit_destination.id])
    end
 end

  def send_relations
    @suite = Suite.find params[:id]
	  permit "editor of :suite" do
	    ids_origin = params["ids_cases_origin"].split(";")
	    ids_destination = params["ids_cases_destination"].split(";")
      @suite.update_cases_relations(ids_origin, ids_destination, params[:content])
	    redirect_to "/suites/relations1/#{@suite.id}"
	end
  end
  
  
  def import_suite
    @projects = Project.find :all, :order=>"name ASC"
    @project = Project.find params[:project_id]
    permit "editor of :project" do
      @projects = @projects - @project.to_a
    end
  
  end
  
  
  
  def save_import_suite
    @project = Project.find params[:project_id]
    permit "editor of :project" do
      @suites = Suite.find params["suites_ids"]  
      @suites.each do |suite|
        suite.copy_to_project(params[:project_id],params["copy_cases"])
      end
    end
  
    redirect_to "/suites"
  end
  
  
  def new_program
    @suite_id  = params[:id]
    @suite     = Suite.find @suite_id
    @init_date = Time.now.to_datetime
    #obtain user configuration
      @user_configuration = UserConfiguration.find_by_user_id(current_user.id)
      @user_configuration_values = @user_configuration.get_hash_values     
      @column_1, @column_2 = ContextConfiguration.calculate_columns
      @suite_execution = SuiteExecution.new
      @command = params[:command]
      
      @cell_selects = ContextConfiguration.build_select_data #Build the selects for edit cell
  end
  
  def create_program
      #Calculating number of minutes between "hours of scheduling" and "current time"
      time_to_run = DateTime.strptime(params[:filter][:init_date], "%d.%m.%Y %H:%M")
      time_to_run = Time.local(time_to_run.year, time_to_run.month, time_to_run.day, time_to_run.hour, time_to_run.min, time_to_run.sec)
      seconds_to_run = time_to_run - Time.now 

      @text_error=""




      if seconds_to_run < 0
       @text_error=_('Invalid Time Format. Time must be after the current.')

      else

      params[:execution][:identifier].gsub!(" ","_")

       if params[:execution][:identifier].match(/^(\w*\_?)*$/).nil? and !params[:execution][:identifier].empty?
            @text_error=_('Field ID must contain only letters, numbers, space or underscore')
       else
         params[:execution][:identifier] = "Suite_Programada" if params[:execution][:identifier].empty?

         params[:execution][:server_port] = request.port if request.port != 80

         a = Delayed::Job.enqueue(RunSuiteProgram.new(params[:execution]), 1, time_to_run)
        
         @job = DelayedJob.find a.id
         @job.add_suite_id(params[:execution][:suite_id])
        
         redirect_to "/suites/calendar/#{params[:execution][:suite_id]}"
       end
    
      end
      
         if !@text_error.empty?
         @js = "top.location='/suites/new_program/#{params[:execution][:suite_id]}'; alert('#{@text_error}')"
         render :inline => "<%= javascript_tag(@js) %>", :layout => true
         end
  end
  
  def delete_program
    @job = DelayedJob.find params[:id]
    @job.destroy
  
    redirect_to "/suites/calendar/0"
  end


  def calendar
    Suite
    
    suites_ids = Rails.cache.read("project_suites_#{params[:project_id]}")
    @suites = Array.new

    if !suites_ids
        project = Project.find params[:project_id] 
        @suites= project.suites
        suites_ids = project.suite_ids
    else
      suites_ids.each do |suite_id|
        @suites << Rails.cache.fetch("suite_#{suite_id}"){Suite.find suite_id}
      end
    end

    if params[:id].nil? or params[:id] == "0"
      #All Suites
      @suite_id = 0
      @programs = DelayedJob.find_all_by_suite_id suites_ids
    else
      #A particular Suite
      @suite_id = params[:id]
      @programs = DelayedJob.find_all_by_suite_id @suite_id
    end
    @suites_names = Hash.new
    @suites.each do |suite|
      @suites_names[suite.id] = suite.name
    end
  end
  
  def suite_tutorial
    
  end
  
  private
  
  def load_categories
    @project = Project.find params[:project_id]
    @categories = @project.categories.find_all_by_parent_id "0"
  end

end
