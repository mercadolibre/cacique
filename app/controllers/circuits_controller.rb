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


require "cgi"

class CircuitsController < ApplicationController

  skip_before_filter	:verify_authenticity_token
  skip_before_filter :context_stuff, :only => :checkit
  
  before_filter :load_categories, :only => [:copy, :delete, :updateCircuit]

  def index

  end
  
  def new
    @category = Category.find params[:cat]
    permit 'editor of :category' do
    end
  end

  #Load Selenium Script
  def uploadFile
    @category  = Category.find(params[:new][:category])
    permit 'editor of :category' do
	    @name = params[:name]
	    if !params[:clean]
	       upload = Hash.new
	       upload[:fileUpload] = params['fileUpload'].read
	       upload[:name] = @name
           upload[:file_name] = params['fileUpload'].original_filename
	       DataFile.save( upload )
	       redirect_to "/circuits/rename?" + "&category_id="+@category.id.to_s+ "&name="+CGI.escape(@name) + "&description="+CGI.escape(params[:description])
	    else
	       #I generate a blank script
	       @circuit  = @category.circuits.new
           @circuit.name        = CGI.escapeHTML(@name)
           @circuit.description = CGI.escapeHTML(params[:description])
           @circuit.user_id     = current_user.id
           @circuit.source_code = ""
           @circuit.save

           #Add the columns of context_configuration.field_default
           context_configurations =  ContextConfiguration.find(:all, :conditions => "enable = '1' AND field_default = 1")
           new_columns = context_configurations.map(&:name).collect {|x| "default_" + x  }
           @circuit.add_case_columns( new_columns )

           #Assign script maker to first version
           @circuit.versions.first.update_attributes(:user_id => current_user.id)
           
           redirect_to "/circuits/#{@circuit.id}/edit"
	    end
	    
    end
  end

 #Script update
 def  updateFile
   content = params[:content].split("_")[1..-1].map{|x| decode_char(x) }.join
   @circuit = Circuit.find( params[:id] )
   
   actual_version = @circuit.versions.last
   @previous_version = actual_version.number
   
    permit 'editor of :circuit' do
      if (car = @circuit.save_source_code(params[:originalcontent], params[:content].split("_")[1..-1].map{|x| decode_char(x) }.join, params[:commit_message])) == true
        #Version
        @previous_version = last_version.number if @previous_version.nil? 

        #Script access registry
        CircuitAccessRegistry.create(:ip_address=>request.remote_ip,:circuit_id=> @circuit.id,:user_id=> current_user.id)
        render :partial => "original_content", :locals => { :source_code => @circuit.source_code, :exito => true, :previous_version => @previous_version, :circuit_id => @circuit.id }
      else
        render :xml => "<div style='color:red;'>" + _("Could not save the script because it is not updated") + "<br>" + _("Last Edit") + ": #{car.user.name} ( #{car.user.login} )"+"\nIP: "+"#{car.ip_address}</div>";
      end
    end

  end


 #Script Data recovery
 def getDataRecovery
      data_recovery_names   = DataRecoveryName.find_all_by_circuit_id params[:id].to_i
      @data_recovery_names  = data_recovery_names.map(&:name)
      @data_recovery_values = data_recovery_names.map(&:code)

      #Column obtainl, excluding exclude_columns
      #for a "Select" Create
      exclude_columns = ["id", "case_template_id", "created_at", "updated_at"]
      @columns_names = (Circuit.find params[:id].to_i).get_columns_names(exclude_columns)
      
      #Adds all the columns of "context_configurations"
      ContextConfiguration.all_enable.each{|c| @columns_names << c.name }
      
      #Edit Permissions
      @circuit  = Circuit.find params[:id].to_i
	    @readonly = true unless current_user.has_role?("editor", @circuit)
      render :partial => "data_recovery"
 end

 #Add Data recovery to Script
  def updateDataRecovery
    DataRecoveryName.create(:circuit_id => params[:id], :name=>params[:name], :code=>params[:code])
    render :nothing => true
  end

  #Delete Data Recovery from Script
  def deleteDataRecovery
    @circuit       = Circuit.find params[:id]
    permit "editor of :circuit" do
      data_recovery_name = @circuit.data_recovery_names.find_by_name(params[:name])
      data_recovery_name.destroy
    end
    render :nothing => true
  end


  def get_suites_of_script 
       circuit  = Circuit.find params[:id].to_i
       suites   = circuit.suites
       render :partial => "suites_of_script", :locals => {:circuit_name=>circuit.name, :suites => suites}
  end

  def editName
	@circuit = Circuit.find params[:circuit_id]
    render :partial => "edit", :locals => {:category => @category}
  end

  def updateCircuit
      @circuit = Circuit.find params[:id]
      if  current_user.has_role?( "editor", @circuit)
        
        if @circuit.update_attributes(:name=> params[:name], :description=>params[:description])
          last_version = @circuit.versions.last
          last_version.user_id = current_user.id
          last_version.save
          text_error = nil
          #text_error = _("Modification was successful")
        else
          text_error = Array.new
          text_error << _("Impossible to modify ")+"#{@circuit.name_was}\n"
          @circuit.errors.full_messages.each {|error|  text_error << error }
        end
        render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => text_error} 
    else
        text_error = [_("Impossible to edit ")+"- "+_("You do not have Edit Permissions")]
        render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => text_error}     
    end
  end

  def rename
    @category    = Category.find params[:category_id]
    @name        = params[:name]
    @description = params[:description]
    @errors      = params[:errors]

    begin
      @fields = Circuit.selenium_data_collector( {:name => "#{RAILS_ROOT}/lib/temp/#{@name}"} )
      #Fields codify
      @fields.each do |t|
        t.id = CGI.escape(t.id)
        t.args = t.args.map{ |a| CGI.escape(a) }
      end
    rescue Exception => @error
      redirect_to "/circuits/error?error=#{@error}&category_id=#{@category.id}"
    end
  end

  def rename_save
    @complete_fields = Hash.new
    @new_fields = Hash.new
    @category = Category.find(params[:circuit][:category_id])
    @circuit  = @category.circuits.new
    @circuit.name        = params[:circuit][:name]
    @circuit.description = params[:circuit][:description]
    @circuit.user_id     = current_user.id

    new_columns = []
    
    if !params[:save].nil?
      #If is not first Scrip
      params[:save].each_pair do |k_,v_|
        k = CGI.unescape(k_)
        if !v_.empty?
          v = CGI.unescape(v_)
          v.gsub!(" ","_")
          v.downcase!
          if v == _("-Select-") or v == _("-select-")
            @complete_fields[k.split("&&")[1]] = nil
          else
            @complete_fields[k.split("&&")[1]] = v.to_s.split("(")[0]
          end
        else
          @complete_fields[k.split("&&")[1]] = nil
        end
      end
      new_columns = @complete_fields.map{|k,v| v.to_s.downcase }.select{|col_name| col_name.to_s != "updated_at" and col_name.to_s != "created_at" and col_name.to_s != "id" and col_name.to_s != "case_template_id" and col_name.to_s != ""}
      new_columns = new_columns.select{|x| x!=""}
      new_columns.collect!{|col| col.downcase.gsub(" ","_")}

      #Add the columns of context_configuration.field_default
      context_configurations =  ContextConfiguration.find(:all, :conditions => "enable = '1' AND field_default = 1")
      context_configurations.each do |context_configuration|
        new_columns << "default_" + context_configuration.name
      end
    end

    #Add columns to script
	if !@circuit.case_column_names_valid?(new_columns)
	   render :partial => "errors", :locals => {:errors => @circuit.errors, :circuit_id => nil} 
	else
	  @circuit.save
	  @circuit.add_case_columns(new_columns)

      if Circuit.selenium_generate_circuit({
        :name => "#{RAILS_ROOT}/lib/temp/#{params[:circuit][:name]}",
        :data => @complete_fields,
        :circuit => @circuit,
        :project_id => params[:project_id],
        })

          #Add Maker
          last_version = @circuit.versions.last
          last_version.user_id = current_user.id
          last_version.save

          #First script create:
          #set field and values in hash
          #Format: [field1=>value1, field2=>value2]
          #Complete_fiels format:{"3:date_5"=>"hello2", "2:TESTDATO_CUATRO"=>"hello1", "5:button"=>"hello4", "4:1912496"=>"hello3"}
          #must flipped to value=>field
          @new_data_set = Hash.new
          @complete_fields.each_pair do |k,v|
          new_value = k.split(':')[1]
            if v != nil
              @new_data_set[v]= new_value
            end
          end
          @circuit.add_first_data_set( @new_data_set )
          #Se tiene que hacer un render al partial de errores porque en la vista las validaciones del
          #formulario se realizan por ajax. Luego en el partial se hace un redirect a circuits edit.
          render :partial => "errors", :locals => {:errors => nil, :circuit_id => @circuit.id} 
      else
          render :action => 'new'
      end
    end
  end

  def import
    @circuit = Circuit.find params[:id]
    permit "editor of :circuit" do
      if @circuit.import( params['fileUpload'], "casos.xls", current_user.id )
        redirect_to "/circuits/#{params[:id]}/case_templates"
      else
        p _("FILE NO SAVED ")
        render :text => _("ERROR TO SAVE FILE IN ")+"#{RAILS_ROOT}/public"
      end
     end 
  end

  def versions
    @circuit = Circuit.find params[:id]
    @versions = @circuit.versions.paginate :page => params[:page], :order => 'id DESC', :per_page => 10
  end

  def edit
    Execution
    
    if !Circuit.exists?(params[:id])
      Circuit.expires_cache_circuit(params[:id], @project_actual)
      redirect_to "/circuits"
      return true
    end
    
    @circuit = Circuit.find params[:id]

    @last_circuit_version = Circuit.find params[:id]
    @project_id = @circuit.category.project_id

    #edit last version?,
    #if not, obtain las version
    if params[:version]
      if params[:version].to_i != @circuit.version
        @version_number = params[:version].to_i
      end
      @circuit.revert_to( params[:version].to_i )
      @version = @circuit.versions.find_by_number( params[:version].to_i )
      #BUGFIX: if script not exist, and user accesses through a url, go to last version
      @version=@circuit.versions.last if @version.nil?
      @version_number=@version.number
    else
      @version = @circuit.versions.last
    end
    #Version
    @previous_version = @circuit.versions.map{|v| v.number}.select{|n| n<@circuit.version}.max
    @next_version = @circuit.versions.map{|v| v.number}.select{|n| n>@circuit.version}.min

    #Edit permission
      @readonly = false
	  @readonly = true unless current_user.has_role?("editor", @circuit)

    permit "viewer of :circuit" do
      @lines = Array.new

      #Obtain last line from script
      source_code = @circuit.source_code.to_s
      source_code.split("\n").each do |record|
        @lines << record.gsub("\n\r","\r").gsub("\r\n","\r").gsub("\n","\r")
      end

      #send DIV to AJAX
      @all_projects = current_user.other_projects
      @my_projects = current_user.my_projects
      

      if params.has_key?(:execution_running)
        #Caching case_template
        Rails.cache.write("last_exec_circuit_#{@circuit.id}",params[:execution_running])
        @execution_running = Rails.cache.fetch("exec_#{params[:execution_running]}"){ Execution.find(params[:execution_running])}
      else
        #search in cache last executed script
        execution_id = Rails.cache.read "last_exec_circuit_#{@circuit.id}"
        if execution_id
          @execution_running = Rails.cache.fetch("exec_#{execution_id}"){ Execution.find( execution_id )}
        else
          @execution_running = nil
        end 
      end
    end

  end

  def delete
    @circuit = Circuit.find params[:circuit_id]
      if  current_user.has_role?( "editor",  @circuit)
       @circuit.destroy
       
       @js = "window.location.reload()"
       render :inline => "<%= javascript_tag(@js) %>"

       #render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => nil}
      else
        text_error = [_("Impossible to delete ")+"- "+_("You do not have Edit permissions, request permissions.")]
        render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => text_error}     
      end
  end

  def shell_escape( str )
	 "'#{str.gsub("\\","\\\\\\\\").gsub("'","\\\\\'").gsub("\"","\\\\\"")}'"
 end

 #Script Copy. With or without cases
 def copy
   	@project = Project.find params[:project_id]
    if  current_user.has_role?( "editor",  @project )
      circuit = Circuit.find params[:circuit_id]
      copy_cases = (params.has_key?('cases'))? "true": "false"
      circuit.copy(copy_cases)
      render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => nil} 
    else
      text_error = [_("Impossible to create ")+"- "+_("You do not have Edit permissions, request permissions.")]
      render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => text_error}     
    end
 end

 def error
   @error = params[:error]
   @category_id = params[:category_id]
   @category = Category.find(@category_id)
   @linea = @error.split(':')[-2]
   @error = @error.split(':')[-1]
 end

  #Ruby Help
 def ruby

 end
 
 def load_categories
   @project = Project.find params[:project_id]
   permit "viewer of :project" do
     @categories = @project.categories.find_all_by_parent_id "0"
   end
 end

 def checkit
   code=params[:code].split("_")[1..-1].map{|x| decode_char(x) }.join
   check_data = Circuit.syntax_checker(code)
   render :partial => "circuits/check_data", :locals => { :status=>check_data[:status], :errors=>check_data[:errors], :warnings=>check_data[:warnings]}
 end
 
  #add new column to Data Set (Use in ABM columns for Case Template)
  def add_column
    @circuit    = Circuit.find params[:id]
    permit "editor of :circuit" do
       @circuit.add_case_columns( [params[:column_to_add]], params[:value_column_to_add] )
       if @circuit.errors.empty?
          redirect_to "/circuits/#{@circuit.id}/case_templates"
        else
          render :controller=>'case_template', :action=>'index'
      end
    end
  end
 
  #Delete column to Data Set
  def delete_column
    @circuit    = Circuit.find params[:id]
    permit "editor of :circuit" do
      begin
         @circuit.delete_case_columns( params[:column][:to_delete] )
         @circuit.save
         redirect_to "/circuits/#{@circuit.id}/case_templates"
      rescue RuntimeError => error
         @circuit.errors.add(:eliminarColumna, error)
         self.index(@circuit)
         render :action=>'index'
      end
    end
  end
 
  #Modify column to Data Set
  def modify_column
    @circuit = Circuit.find params[:id]
    permit "editor of :circuit" do
      begin
        @circuit.modify_case_columns( params[:column][:to_modify], params[:column_name_to_modify] )
        @circuit.save
        redirect_to "/circuits/#{@circuit.id}/case_templates"
      rescue RuntimeError => error
        @circuit.errors.add(:nuevaColumna, error)
        self.index(@circuit)
        render :action=>'index'
      end
    
    end
  end
  
  def script_tutorial
    
  end
  
end
