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
    respond_to do  |format|
       format.html
       format.xml{render :index,:layout=> false }
    end
  end
  
  def new
    @category = Category.find params[:category_id]
    permit 'editor of :category' do
    end
  end

  #Load Selenium Script
  def create
    @category  = Category.find(params[:new][:category])
    permit 'editor of :category' do
	    @name = params[:name]
	    if !params[:clean]
	       upload = Hash.new
	       upload[:fileUpload] = params['fileUpload'].read
	       upload[:name] = @name
         upload[:file_name] = params['fileUpload'].original_filename
	       DataFile.save( upload )
	       redirect_to url_for(:controller=>:circuits, :action=>:rename, 
                                   :project_id=>params[:project_id], :error=>@error, :category_id=>@category.id, 
                                   :name=>CGI.escape(@name), :description=>CGI.escape(params[:description]) )
	    else
	       #I generate a blank script
               @circuit = Circuit.create(:project_id =>@category.project_id, :category_id => @category.id, 
                                         :name=> CGI.escapeHTML(@name), :description=> CGI.escapeHTML(params[:description]),
                                         :user_id=> current_user.id, :source_code => "")

               #Add the columns of context_configuration.field_default
               context_configurations =  ContextConfiguration.find(:all, :conditions => "enable = '1' AND field_default = 1")
               new_columns = context_configurations.map(&:name).collect {|x| "default_" + x  }
               @circuit.add_case_columns( new_columns )

               #Assign script maker to first version
               @circuit.versions.first.update_attributes(:user_id => current_user.id)
               redirect_to edit_project_circuit_path(@circuit.project_id,@circuit) 
	    end   
    end
  end

 #Script update
 def  update
   @circuit = Circuit.find( params[:id] )
   #Update SOURCE CODE 
   if params[:name].nil?
      content = params[:content].empty? ? "" : params[:content].split("_")[1..-1].map{|x| decode_char(x) }.join   
      #Version
      @previous_version = @circuit.versions.last.number
      permit 'editor of :circuit' do
         # Verified if another user has edited the script
         if (@circuit.updated_at.to_s != params[:last_updated_at])
          @text_error =  _("Unable to save! ") + ". "
          @text_error += _("It was edited by the user ") + User.find(@circuit.versions.last.user_id).name + ". "
          @text_error += _("Save your changes in another medium, refresh the page and try again")
         else
           @circuit.save_source_code(content,params[:commit_message])
         end
         @play = true if params[:and_play]
         respond_to do |format|
          format.js # run the update.rjs template
         end
     end
   else
      #Update NAME and DESCRIPTION 
      if  current_user.has_role?( "editor", @circuit)  
        if @circuit.update_attributes(:name=> params[:name], :description=>params[:description])
          last_version = @circuit.versions.last
          last_version.user_id = current_user.id
          last_version.save
          text_error = nil
        else
          text_error = Array.new
          text_error << _("Impossible to modify ")+"#{@circuit.name_was}\n"
          @circuit.errors.full_messages.each {|error|  text_error << error }
        end
      else
        text_error = [_("Impossible to edit ")+"- "+_("You do not have Edit Permissions")]
      end
      render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @circuit.project, :text_error => text_error}   
   end

  end

  def get_suites_of_script 
       circuit  = Circuit.find params[:id].to_i
       suites   = circuit.suites
       render :partial => "suites_of_script", :locals => {:circuit_name=>circuit.name, :suites => suites}
  end

  def rename
    @category    = Category.find params[:category_id]
    @name        = params[:name]
    @description = params[:description]
    @errors      = params[:errors]
    begin
      @fields = Parser.parser_data( "#{RAILS_ROOT}/lib/temp/#{@name}" )
    rescue Exception => errors
      @errors = errors
      render :action => 'new'
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
    @circuit.project_id  = @category.project_id

    #New columns
    new_columns = []
    if params[:save]
      fields = params[:save].each{|value, field_name| field_name.downcase.gsub(" ","_")}
      columns_default  = ["updated_at" , "created_at", "id", "case_template_id"]
      fields.each do |value, field_name|
         @complete_fields[field_name]=CGI.unescape(value)  if !columns_default.include?(field_name) and !field_name.empty? and !value.empty?
      end 
      new_columns = @complete_fields.keys

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

      if Parser.generate_script(@complete_fields, @circuit)
          #Add Maker
          last_version = @circuit.versions.last
          last_version.user_id = current_user.id
          last_version.save

          @circuit.add_first_data_set( @complete_fields )
          #Se tiene que hacer un render al partial de errores porque en la vista las validaciones del
          #formulario se realizan por ajax. Luego en el partial se hace un redirect a circuits edit.
          render :partial => "errors", :locals => {:errors => nil, :circuit_id => @circuit.id} 
      else
          render :action => 'new'
      end
    end
  end

  def import
    @circuit = Circuit.find params[:circuit_id]
    permit "editor of :circuit" do
      if @circuit.import( params['fileUpload'], "casos.xls", current_user.id )
        redirect_to project_circuit_case_templates_path(@circuit.project_id,@circuit)
      else
        p _("FILE NO SAVED ")
        render :text => _("ERROR TO SAVE FILE IN ")+"#{RAILS_ROOT}/public"
      end
     end 
  end

  def edit
   if params[:rename]
   #Edit NAME and DESCRIPTION
      @circuit = Circuit.find params[:circuit_id]
      render :partial => "edit", :locals => {:category => @category}
   else
   #Edit SOURCE CODE
      Execution
      DataRecovery
      DataRecoveryName    
      if !Circuit.exists?(params[:id])
        Circuit.expires_cache_circuit(params[:id], @project_actual)
        redirect_to "/circuits"
        return true
      end
      @user_functions_names = Rails.cache.read("functions") || []
      @circuit = Circuit.find params[:id]
      @last_circuit_version = Circuit.find params[:id]
      @project_id = params[:project_id]
  
      #edit last version?,
      #if not, obtain last version
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
      @readonly = !current_user.has_role?("editor", @circuit)

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

        #Search in cache last executed script
        @execution_running = @circuit.get_last_execution

     end
     respond_to do |format|
       format.html
       format.xml{ render :edit, :layout=> false }
     end
   end
  end

  def destroy
    @circuit = Circuit.find params[:circuit_id]
      if  current_user.has_role?( "editor",  @circuit)
       @circuit.destroy
       @js = "window.location.reload()"
       render :inline => "<%= javascript_tag(@js) %>"
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

 def load_categories
   @project = Project.find params[:project_id]
   permit "viewer of :project" do
     @categories = @project.categories.find_all_by_parent_id "0"
   end
 end

 def checkit
   code= params[:code].empty? ? "" : params[:code].split("_")[1..-1].map{|x| decode_char(x) }.join
   check_data = Circuit.syntax_checker(code)
   render :partial => "circuits/check_data", :locals => { :status=>check_data[:status], :errors=>check_data[:errors], :warnings=>check_data[:warnings]}
 end

end
