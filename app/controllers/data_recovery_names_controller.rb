class DataRecoveryNamesController < ApplicationController


   def index
      @data_recovery_names   = DataRecoveryName.find_all_by_circuit_id params[:circuit_id].to_i
      @project_id = params[:project_id]
      #Column obtainl, excluding exclude_columns
      #for a "Select" Create
      exclude_columns = ["id", "case_template_id", "created_at", "updated_at"]
      @columns_names = (Circuit.find params[:circuit_id].to_i).get_columns_names(exclude_columns)
      
      #Adds all the columns of "context_configurations"
      ContextConfiguration.all_enable.each{|c| @columns_names << c.name }
      
      #Edit Permissions
      @circuit  = Circuit.find params[:circuit_id].to_i
      @readonly = true unless current_user.has_role?("editor", @circuit)
      render :partial => "data_recovery_names"
   end

   def new
   end

   #Add Data recovery to Script
   def create
    DataRecoveryName.create(:circuit_id => params[:circuit_id], :name=>params[:name], :code=>params[:code])
    render :nothing => true
   end

   
   def destroy
    data_recovery_name = DataRecoveyName.find(params[:id])
    @circuit       = Circuit.find data_recovery_name.circuit_id
    permit "editor of :circuit" do
      data_recovery_name.destroy
    end
    render :nothing => true
   end


end
