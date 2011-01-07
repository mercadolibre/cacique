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


class SuiteExecutionsController < ApplicationController

  require 'spreadsheet/excel'
  include Spreadsheet
  include SuiteExecutionsHelper

  protect_from_forgery :except => [:create, :show]
  skip_before_filter :verify_authenticity_token
  
  skip_before_filter :context_stuff, :only => [:update_suite_execution_status, :update_executions_status]

  def index

    @project ||= Project.find params[:project_id]
    @errores = Array.new
    CalendarDateSelect.format=(:finnish) 
    today = Time.now
    
    @init_date  = params[:filter] && params[:filter][:init_date]?   DateTime.strptime(params[:filter][:init_date], "%d.%m.%Y %H:%M"): ("1." + today.month.to_s + "." + today.year.to_s).to_datetime
    @finish_date= params[:filter] && params[:filter][:finish_date]? DateTime.strptime(params[:filter][:finish_date], "%d.%m.%Y %H:%M") : today.to_datetime.in_time_zone
    @readonly = true unless current_user.has_role?("editor", @project)


   #show filters
   if params[:filter]

      @show_model = params[:filter][:model]
      @suite_names ||= @project.suites
      @script_names ||= @project.circuits      
      @suite_names ||= @project.suites
      @script_names ||= @project.circuits   
      
      row_per_page= (!params[:filter][:paginate].nil? && !params[:filter][:paginate].empty?)? params[:filter][:paginate].to_i : 12
      identifier  = params[:filter][:identifier]

      #select cases values
      if params[:filter][:circuit_id] && !params[:filter][:circuit_id].empty?
         circuit = Circuit.find params[:filter][:circuit_id]
         @case_names = circuit.case_templates
      end

     case params[:filter][:model]
      #SUITES
      when "suites"
            suites_ids = (params[:filter][:suite_id].empty?)? @project.suite_ids : params[:filter][:suite_id]
            @suite_executions=SuiteExecution.project_id_equals(@project.id).identifier_like(identifier).created_at_lte(@finish_date.to_datetime+(2/24.0)).created_at_gte(@init_date.to_datetime+(2/24.0)).paginate_all_by_suite_id suites_ids, :order => 'created_at DESC', :include => [{:executions => :case_template}, {:suite => :circuits}], :page => params[:page], :per_page => row_per_page
      #SCRIPTS
      when  "scripts"
            suites_executions = (@project.suite_executions.find_all_by_suite_id 0)
            #search an specific script
            if !params[:filter][:circuit_id].nil? and !params[:filter][:circuit_id].empty? 
             #execution id for searched script
             suites_executions_ids = Array.new()
             suites_executions.each do |se|
               #filter per cases
               if params[:filter][:case_id].nil? or params[:filter][:case_id].empty?
                  suites_executions_ids << se.id if params[:filter][:circuit_id].include?(se.executions.first.circuit_id.to_s)
               else
                  suites_executions_ids << se.id if (params[:filter][:case_id].include?(se.executions.first.case_template_id.to_s) and params[:filter][:circuit_id].include?(se.executions.first.circuit_id.to_s))
               end
              end
            #All Scripts
            else
               suites_executions_ids = suites_executions.map(&:id)
            end
            @suite_executions = SuiteExecution.project_id_equals(@project.id).identifier_like(identifier).created_at_less_than_or_equal_to(@finish_date.to_datetime+(2/24.0)).created_at_greater_than_or_equal_to(@init_date.to_datetime+(2/24.0)).paginate_all_by_id suites_executions_ids , :order => 'created_at DESC', :include => [{:executions => :case_template}, {:suite => :circuits}], :page => params[:page], :per_page => row_per_page
      #SCRIPTS Y SUITES
      else
        suites_ids = @project.suite_ids #Suites
        suites_ids << 0                #Scripts
        @suite_executions=SuiteExecution.project_id_equals(@project.id).identifier_like(identifier).created_at_less_than_or_equal_to(@finish_date.to_datetime+(2/24.0)).created_at_greater_than_or_equal_to(@init_date.to_datetime+(2/24.0)).paginate_all_by_suite_id suites_ids , :order => 'created_at DESC', :include => [{:executions => :case_template}, {:suite => :circuits}], :page => params[:page], :per_page => row_per_page
     end
   #Without filters
   else
       @suite_executions = @project.suite_executions.paginate :page => params[:page], :per_page => 11, :order => 'created_at DESC'
   end

   #Run configurations
   @run_configurations = Hash.new
   @suite_executions.each do |se| 
       @run_configurations[se.id] = se.execution_configuration_values
   end
   
  end

  def show_model_filter
    @show_model = params[:filter][:model]
    project ||= Project.find params[:project_id]
    @suite_names, @script_names, @case_names = Array.new
    (@show_model == "scripts")? @script_names=project.circuits : @suite_names=project.suites
    
    render :partial => "filter_model_div", :locals => {:show_model =>@show_model, :suite_names=>@suite_names, :script_names=>@script_names, :case_names=>@case_names}
  end
  
  def show_cases_filter
     case_names  = Array.new
     if !params[:filter][:circuit_id].empty?
       circuit = Circuit.find params[:filter][:circuit_id]
       case_names = circuit.case_templates
     end
     render :partial => "filter_script", :locals => {:case_names=>case_names}
  end


  def export_popup
    render :layout => false
  end

  def show
    SuiteExecution
    Execution
    ExecutionConfigurationValue
    Circuit
    #if suite_execution was runned should be in cache
    unless params[:id].include?("_")
      @all_suite_execution = Rails.cache.fetch("suite_exec_#{params[:id]}"){ s = SuiteExecution.find params[:id]; [s,s.execution_ids] }
      if @all_suite_execution
        @suite_execution = @all_suite_execution[0]
        @executions = @suite_execution.ordenar_executions(@suite_execution.executions_cache(@all_suite_execution[1]))
      else
        @suite_execution = SuiteExecution.find(params[:id], :include => [:executions, {:suite => :circuits}])
        @executions = @suite_execution.ordenar_executions(@suite_execution.executions)
      end

      @exec_conf_values = @suite_execution.execution_configuration_values
  
      #Suite name validation.
      @name = (@suite_execution.suite.nil?)? @suite_execution.executions.first.circuit.name : @suite_execution.suite.name
    end
    respond_to do |format|
      format.html do 
       render "#{RAILS_ROOT}/app/views/suite_executions/show.haml", :layout=>true  #TODO: fix this
      end
      format.xml do
      @suite_execution = SuiteExecution.find params[:id].split("_")
      render :template => 'suite_executions/show.rxml', :layout => false
     end
      format.json{ render :json => @suite_execution.to_json }
      format.text{ render :text => @suite_execution.to_yaml }
    end
  end


  def suite_execution_detail
    @suite_execution = SuiteExecution.find params[:id]
  end


  def new
      @suite =Suite.find params[:suite_id]
      @user_configuration = UserConfiguration.find_by_user_id(current_user.id) 
      @user_configuration_values = @user_configuration.get_hash_values
      
      @column_1, @column_2 = ContextConfiguration.calculate_columns
      @cell_selects        = ContextConfiguration.build_select_data #Build the selects for edit cell
      @command = params[:command]
      @suite_execution = SuiteExecution.new
  end

  def create

    if !params[:execution].nil? and params[:execution].include?(:suite_id) 
      #if run a suite, i have suite_id
      suite_id = params[:execution][:suite_id]
      @suite = Suite.find params[:execution][:suite_id], :include => {:schematics => :case_template}
      cant_corridas = params[:execution][:cant_corridas]
    else
      #if run a cases, i not have suite_id
      suite_id = "0"
      cant_corridas = "1"
      @project_id = params[:project_id]
    end
    
    @user_configuration = current_user.user_configuration
    #Identifier seting

    identifier = ""
    #if come from case_template use User configuration.
    #if come from suite update configuration.
    if params.include?(:execution)
      @user_configuration.update_configuration(params[:execution])
      emails_to_send = @user_configuration.emails_to_send
      identifier = params[:execution][:identifier]
    else
      emails_to_send = current_user.email
    end
    #search the number of combinations that I can do with run configuration
    #[{:site => "ar"},{:site => "br"}]
    combinations = @user_configuration.run_combinations
  
    suite_executions = []
    circuit_id = 0
    
    combinations.each do |combination|
      @project_id ||= Suite.find(suite_id).project_id 
      @suite_execution = SuiteExecution.create(:suite_id=>suite_id,:project_id=>@project_id, :identifier=>identifier,:user_id=>current_user.id)
      #add run parameters to suite_execution
      @suite_execution.create_configuration_to_run(combination)     
      #Executions are generated for the suite

      options = {:suite_id => suite_id}
      options[:case_comment] = params[:execution][:case_comment] if params.include?(:execution)
      if suite_id != "0"
        options[:suite] = @suite
      end 
      if params.include?(:execution_run)
        options[:execution_run] = params[:execution_run] 
        circuit_id = CaseTemplate.find(params[:execution_run].first).circuit_id
      end
      
      if params.include?(:case_template_id)
        options[:case_template_id] = params[:case_template_id] 
        options[:circuit_id] = params[:circuit_id]
        circuit_id = params[:circuit_id]
      end
      
      @suite_execution.calculate_executions(options)
      #caching suite_execution
      @suite_execution.load_cache          
      #caching last executions of suite_execution
      @suite_execution.load_last_executions_cache    
      
      suite_executions << @suite_execution
    end
    

    suite_container_id = 0
   
    #Hash con parametros que se pasan al controlador
    options = { :project_id => params[:project_id],
                :debug_mode => @user_configuration.debug_mode,
                :remote_control_mode => @user_configuration.remote_control_mode,
                :remote_control_addr => @user_configuration.remote_control_addr,
                :remote_control_port => @user_configuration.remote_control_port,
                :send_mail => @user_configuration.send_mail,
                :emails_to_send => emails_to_send,
              }
    #if suite_execution has not project_id (i.e when is called from the comman line) it should take it value from the relation 
              
      cant_corridas = "1" if cant_corridas.nil? 
      cant_corridas = "1" if cant_corridas.empty?
      not_continue = false
      if cant_corridas != "1"
        @suite_container = SuiteContainer.new
        @suite_container.times = cant_corridas.to_i
        @suite_container.suite_id = @suite_execution.suite_id
        @suite_container.save
        suite_container_id = @suite_container.id
        @suite_execution.suite_container_id = @suite_container.id
        @suite_execution.save
        #save suite_container in cache
        Rails.cache.write("suite_container_#{@suite_container.id}",[@suite_container,[@suite_execution.id]],:expires_in => CACHE_EXPIRE_SUITE_EXEC)
        #Run suite_executions N Times
        options[:suite_executions] = suite_executions
        options[:veces] = cant_corridas.to_i
        options[:suite_container_id] = suite_container_id
        options[:suite_container_tag] = "suite_container_#{suite_container_id}"    
        begin
            ExecutionWorker.asynch_run_n_times(options)
        rescue Exception => e
            if e.class == Workling::QueueserverNotFoundError or e.class == Workling::WorklingConnectionError
              redirect_to "/suite_executions/workling_error"
              not_continue = true
            else
              raise e
            end
        end
      else
        #Run any suite per time
        suite_executions.each do |suite_execution|
          options[:suite_execution_id] = suite_execution.id
          options[:suite_execution_tag] = "suite_exec_#{suite_execution.id}"
          options[:configuration_values] = suite_execution.hash_execution_configuration_values
          
          begin
            ExecutionWorker.asynch_run_suite(options)
          rescue Exception => e
            if e.class == Workling::QueueserverNotFoundError or e.class == Workling::WorklingConnectionError
              redirect_to "/suite_executions/workling_error"
              not_continue = true
              break
              #TODO:Falta pasar a status no se ejecuto todos los registros
            else
              raise e
            end
          end
          
        end
      end
    if !not_continue
      if params[:where_did_i_come] == "case_templates_index"
        url = "/circuits/#{circuit_id}/case_templates"
      elsif params[:where_did_i_come] == "circuits_edit"
        url = "/circuits/edit/#{circuit_id}?execution_running=#{suite_executions.last.executions.first.id}"
      elsif params[:where_did_i_come] == "suite_executions_new"
        if params[:execution][:cant_corridas] != "1"
          #Run Suite N Times
          url = "/suite_executions"   
          #Run 1 time
        else
          #Run wth convinations
          if combinations.length> 1
            url = "/suite_executions"
          else   
            url = "/suite_executions/#{suite_executions.last.id}"
          end
        end
      else
        #redirect to suite_execution show
        url = "/suite_executions/#{suite_executions.last.id}"
      end

      if @suite_execution.save
        respond_to do |format|
          format.text do 
            render :text => suite_executions.map(&:id).join("_") 
          end
          format.html do 
            redirect_to url  
          end
          format.xml do 
            render :xml => @suite_execution.to_xml 
          end
        end
      end
    end
  end 

  #suite execution finish? return TRUE
  def refresh
    values=params[:id].split "_"
    result=true
    values.each do |v|
      unless SuiteExecution.find(v.to_i).finished?
        result=false
        break
      end
   end 
    render :text => result.to_s
  end


  #execution status refresh
  def update_executions_status
    Execution
    Circuit
    #search suite runned in cache
    execution  = Rails.cache.fetch("exec_#{params[:execution]}"){Execution.find(params[:execution])}

    #Call GROUP EXECUTION refresh if is necesary
    render :partial => 'periodically_call_remote_execution_show', :locals => {:execution => execution}
  end

  #Suite execution status refresh for SHOW
  def update_suite_execution_status_show
    SuiteExecution
    Execution
    Circuit
    ExecutionConfigurationValue
    #search suite execution in cache
    suite_execution = Rails.cache.fetch("suite_exec_#{params[:suite_execution]}"){ s = SuiteExecution.find params[:suite_execution]; [s,s.execution_ids] }  

    #Call refresh if is necesary
    render :partial => 'periodically_call_remote_suite_execution_show', :locals => {:suite_execution => suite_execution[0]}
  end
 
  #Suite execution status refresh for INDEX
  def update_suite_execution_status_index
    SuiteExecution
    Execution
    Circuit
    ExecutionConfigurationValue
    #search suite execution in cache
    suite_execution = Rails.cache.fetch("suite_exec_#{params[:suite_execution]}"){ s = SuiteExecution.find params[:suite_execution]; [s,s.execution_ids] }  

    #Call refresh if is necesary
    render :partial => 'status', :locals => {:suite_execution => suite_execution[0]}
  end  
  
  
  #SUITE_COMMENT
  def suite_comment
   @suite = Suite.find(params[:id])
   @circuits_cases    = Hash.new
   @circuit_case      = Hash.new
   @circuit_relations = Hash.new
   @cell_selects      = ContextConfiguration.build_select_data #Build the selects for edit cell

    #Cases Script
      #Hash con formato: id caso-> nombre circuito)
      @suite.case_templates.each do |c|
	       @circuit_case[c.id] = c.circuit.name
	    end

    #case template table
      @exclude_show      = [ :circuit_id, :user_id, :updated_at, :case_template_id]
      @exclude_show_data = [:id, :case_template_id, :updated_at, :created_at]
      @columns_template  = CaseTemplate.column_names
 
      #Script column obtain
         #hash Format: [circuit_id =>{data sets column}]
         @suite_circuits_data = Hash.new
         @suite_circuits_data = @suite.circuits_data()

    #Broken relations
    @circuits  = @suite.circuits
    @relations = SuiteFieldsRelation.find(:all, :conditions => "suite_id= #{@suite.id}")

    #Hash Format:{caso_origen.id => [SuiteCasesRelation1, SuiteCasesRelation2, ...]}
      @case_relations = Hash.new
      @suite.case_templates.each do |c|
         @case_relations[c.id] = @suite.suite_cases_relations.find_all_by_case_origin c.id
      end

    #obtain script cases
    #hash Format:{circuit.id => [case1, case2, ...]}
    @suite_circuit_cases = Hash.new
    @circuits.each do |circuit|
         @suite_circuit_cases[circuit.id] = @suite.case_templates.find_all_by_circuit_id circuit.id
    end
    
    render :partial => "/suite_executions/suite_comment", :locals => {:suite=>@suite,:case_relation=>@case_relation,:circuits_ids=>@circuits_ids,:circuits_names=>@circuits_names,:circuits=>@circuits,:suite_circuits_data=>@suite_circuits_data}
  end
  
  def get_report
      unless params[:suite_executions].nil?
        respond_to do |format|
           @executions=SuiteExecution.find(params[:suite_executions].reverse.collect!{|x| x.to_i}) 
           prawnto :prawn=>{:page_size=>"A4",:background=>"#{RAILS_ROOT}/public/images/cacique/pdf_background.jpg", :inline=>false, :filename => "cacique_report.pdf"}
           format.pdf{ render :layout => false  }
        end
      else
        render :text => _('Must Select any Suite')
      end
  end
  
  def update_data
    suite_execution = SuiteExecution.find params[:suite_id]
    suite_execution.identifier = params[:new_value]
    suite_execution.save
    render :nothing => true
  end
  
  def generate_command
    #Save User Configuration
    @user_configuration = current_user.user_configuration
    @user_configuration.update_configuration(params[:execution])

    command = SuiteExecution.generate_command( params[:execution], "run")
  
    if params[:execution]["where_did_i_come"] == "new_program"
      redirect_to :controller => "suites", :action => "new_program", :command => command, :id => params[:execution][:suite_id], :cases => params[:execution][:cases_to_run].to_a
    else
      redirect_to :action => "new", :command => command, :suite_id => params[:execution][:suite_id], :cases => params[:execution][:cases_to_run].to_a
    end
  end
  
  def workling_error
  
  end
end
