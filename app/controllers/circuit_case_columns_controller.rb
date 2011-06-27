class CircuitCaseColumnsController < ApplicationController


  def edit
    @circuit    = Circuit.find params[:circuit_id]
    permit "editor of :circuit" do
        @circuit_case_colum = CircuitCaseColumn.find params[:id]
        render :partial => "edit_form", :locals => {:circuit=>@circuit, :circuit_case_column=>@circuit_case_colum}
    end

  end



  #CREATE column to Data Set (Use in ABM columns for Case Template)
  def create
    @circuit    = Circuit.find params[:circuit_id]
    permit "editor of :circuit" do
       name =  params[:circuit_case_column][:name]
       value = params[:circuit_case_column][:value]
       if name.empty?
           @js = "top.location='#{project_circuit_case_templates_path(@circuit.project_id,@circuit)}'; alert('#{_('You must complete the name')}')"
           render :inline => "<%= javascript_tag(@js) %>", :layout => true
       else
           @circuit.add_case_columns( [name], value )
           redirect_to project_circuit_case_templates_path(@circuit.project_id,@circuit)
       end
    end
  end


  def update
    @circuit = Circuit.find params[:circuit_id]
    permit "editor of :circuit" do
       if params[:circuit_case_column][:name].empty?
           @js = "top.location='#{project_circuit_case_templates_path(@circuit.project_id,@circuit)}'; alert('#{_('You must complete the name')}')"
           render :inline => "<%= javascript_tag(@js) %>", :layout => true
       else
           cirucit_case_column = CircuitCaseColumn.find params[:id]
           @circuit.modify_case_columns( cirucit_case_column.name, params[:circuit_case_column][:name] )
           redirect_to project_circuit_case_templates_path(@circuit.project_id,@circuit)
       end
    end

  end

  def destroy
    @circuit    = Circuit.find params[:circuit_id]
    permit "editor of :circuit" do
      circuit_case_column    = CircuitCaseColumn.find params[:id]
      circuit_case_column.destroy 
      redirect_to project_circuit_case_templates_path(@circuit.project_id,@circuit)
    end
  end

end
