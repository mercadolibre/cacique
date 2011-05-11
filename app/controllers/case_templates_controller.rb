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


class CaseTemplatesController < ApplicationController

  skip_before_filter :find_projects, :only => :update_status


  def index

    #Circuit
    @circuit = Circuit.find(params[:circuit_id])

    #Case Templates 
    conditions      = CaseTemplate.build_conditions(params) 
    cases_pag       = CaseTemplate.find :all, :conditions=> conditions
    @case_templates = cases_pag.paginate :page => params[:page], :per_page => 10 

    #Variables
    @case_template_columns = CaseTemplate.column_names - ["circuit_id", "user_id", "updated_at", "case_template_id"] #Columns default (id, objective,etc..)
    @circuit_case_columns  = @circuit.circuit_case_columns  #Columns variables 
    @columns_data_show     = CircuitCaseColumn.find_all_by_circuit_id(@circuit.id).select{|x| !x.default?} #Columns case template variables without default
    @cell_selects          = ContextConfiguration.build_select_data #Build the selects for edit cell

  end



  def update_status
    if params[:case_template] == "0"
      #self script refresh
      case_template_id = 0
      circuit = Circuit.find params[:circuit_id]
      execution = circuit.last_execution_self
    else
      #any script run refresh
      case_template  = CaseTemplate.find(params[:case_template])
      case_template_id = case_template.id
      execution = case_template.last_execution
    end
    render :partial => 'status', :locals => {:execution => execution, :case_template_id => case_template_id }
  end


  def create
    @new_case_data = Hash.new
    @circuit = Circuit.find(params[:circuit_id])

    permit "creator_of_case_templates of :circuit" do
      @case_template            = CaseTemplate.new
      @case_template.objective = _("Complete an objetive doing double click")
      @case_template.user_id    = current_user.id
      @case_template.circuit_id = @circuit.id
      @case_template.save


      # Asign edit permitions
      current_user.has_role("editor", @case_template, :nocheck)

      #add column to case
      @columns_data = CaseTemplate.data_column_names( @circuit )
      @columns_data.each do |column|
        @new_case_data[column] = ''
      end

      @case_template.add_case_data(@new_case_data)
      @case_template.save

      redirect_to project_circuit_case_templates_path(@circuit.project_id,@circuit)

    end   
  end


  def update_data
    column_name = params[:column_name]
    #new value decode
    if params[:new_value] == ""
      new_value = ""
    else
      new_value = params[:new_value].split("_")[1..-1].map{|x| decode_char(x) }.join
    end
    case_template = CaseTemplate.find( params[:case_template_id] )

    if column_name == "objective" or column_name == "priority"
      case_template[column_name]  = new_value
    else
      data = case_template.get_case_data
      data[column_name.to_sym] = new_value
      case_template.update_case_data( data )
    end

    case_template.save
    render :nothing => true

  end

  def update

    @case_template = CaseTemplate.find params[:case_template][:case_template_id]

    @circuit = Circuit.find(@case_template.circuit_id)
    @case_data = @case_template.get_case_data

    attributes_template = Hash.new
    attributes_data = Hash.new
    attributes_template = params[:case_template][:template]
    attributes_data = params[:case_template][:data]


    attributes_template[:circuit_id] = @circuit.id
    attributes_template[:user_id] = current_user.id
    attributes_template[:created_at] = @case_template.created_at
    attributes_data[:case_template_id] = @case_template.id
    attributes_data[:created_at] = @case_data[:created_at]

    @case_template.update_case_data( attributes_data )

    if @case_template.update_attributes(attributes_template) and @case_template.save
      redirect_to "/circuits/#{@case_template.circuit_id}/case_templates"
    end
  end


  def export
      @circuit = Circuit.find(params[:circuit_id])
      #Generate all XLS for script case_templates
      send_file "#{RAILS_ROOT}/public/excels/casos_de_#{@circuit.id}.xls" if @circuit.export_cases    
  end

  def delete
    if params[:id]
      @case_template = CaseTemplate.find params[:id]

      permit "editor of :case_template" do
        @case_template.destroy
        redirect_to "/circuits/" + @case_template.circuit_id.to_s + "/case_templates"
      end
    else
      params[:execution_run].each do |case_template_id|
        @case_template = CaseTemplate.find case_template_id
        permit "editor of :case_template" do
          @case_template.destroy
        end
      end
    end

    begin
      redirect_to "/circuits/" + @case_template.circuit_id.to_s + "/case_templates"
    rescue ActionController::DoubleRenderError
    end

  end

  def show
    @case_template  = CaseTemplate.find params[:id]
    @executions      = Execution.paginate_all_by_case_template_id @case_template.id, :order => 'created_at DESC', :conditions=>  ["case_template_id=?", @case_template.id], :page => params[:page], :per_page => 10
  end

end
