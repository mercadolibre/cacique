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
     @project_id = params[:project_id]
     @circuit_id = params[:circuit_id]
     @circuit    = Circuit.find @circuit_id
     permit "editor of :circuit" do
       name = params[:data_recovery_name][:name]
       code = params[:data_recovery_name][:code].empty? ? params[:data_recovery_name][:code_2] : params[:data_recovery_name][:code]
       #Create data recovery name
       @data_recovery_name = DataRecoveryName.create(:circuit_id => @circuit_id, :name=>name, :code=>code)
       respond_to do |format|
           format.js # run the create.rjs template
       end
    end
   end

   
   def destroy
    data_recovery_name     = DataRecoveryName.find(params[:id])
    @data_recovery_name_id = data_recovery_name.id
    @circuit               = Circuit.find data_recovery_name.circuit_id
      permit "editor of :circuit" do
      data_recovery_name.destroy
      respond_to do |format|
        format.js # run the destroy.rjs template
      end
    end
   end


end
