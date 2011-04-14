class DataRecoveriesController < ApplicationController

   def index
      data_recovery_names   = DataRecoveryName.find_all_by_circuit_id params[:circuit_id].to_i
      @data_recovery_names  = data_recovery_names.map(&:name)
      @data_recovery_values = data_recovery_names.map(&:code)

      #Column obtainl, excluding exclude_columns
      #for a "Select" Create
      exclude_columns = ["id", "case_template_id", "created_at", "updated_at"]
      @columns_names = (Circuit.find params[:circuit_id].to_i).get_columns_names(exclude_columns)
      
      #Adds all the columns of "context_configurations"
      ContextConfiguration.all_enable.each{|c| @columns_names << c.name }
      
      #Edit Permissions
      @circuit  = Circuit.find params[:circuit_id].to_i
	    @readonly = true unless current_user.has_role?("editor", @circuit)
      render :partial => "data_recovery"
   end

   def new
   end

   #Add Data recovery to Script
   def create
    DataRecoveryName.create(:circuit_id => params[:id], :name=>params[:name], :code=>params[:code])
    render :nothing => true
   end

   def delete
   end
   
   def destroy
   end



end
