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


class ContextConfigurationsController < ApplicationController
  permit "root" , :only => [:index, :new, :create, :edit, :update, :disable]

  def index
      @context_configurations = ContextConfiguration.all_enable
  end
  
  def new
    @context_configuration = ContextConfiguration.new
    @view_types = ['checkbox','radiobutton','select','input','boolean']
  end

  def create
    
       @context_configuration = ContextConfiguration.new
       @context_configuration.name = params[:context_configuration][:name]
       @context_configuration.view_type = params[:context_configuration][:view_type]
       @context_configuration.field_default = params[:context_configuration][:field_default]
       @context_configuration.process_values(params[:values], params[:context_configuration][:values], params[:context_configuration][:view_type])
       
    #FIELD DEFAULT    
      #if the configuration is default field
      if @context_configuration.field_default     
        #Verify if the column already exists in Cacique
        circuits = Circuit.circuits_with_column("default_" + @context_configuration.name)

        if !circuits.empty?  
          circuits.each do |c|
              @context_configuration.errors.add(:name,_("Column "+"default_#{@context_configuration.name}"+", already exist in Data Set belonging to Script "+"#{c.name}"))
            end
        else
          @context_configuration.save
          #Add the column of context_configuration.field_default in case templates
          circuits = Circuit.all
          column_name = "default_" + @context_configuration.name
          circuits.each do |c|
               c.add_case_columns( column_name )
          end
        end
     end
  
    @context_configuration.add_configuration_to_all_user if @context_configuration.save
    
    if @context_configuration.errors.empty?
      redirect_to "/context_configurations"
    else
      @view_types = ['checkbox','radiobutton','select','input','boolean']
      render "new", :locals => {:context_configuration => @context_configuration}
    end
  
  end
  
  def edit
    @context_configuration = ContextConfiguration.find params[:id]
    @all_values = @context_configuration.values.split(";")
    #The values are deleted in context_configuration to not be displayed on the form
    @context_configuration.values = ""
    @view_types = ['checkbox','radiobutton','select','input','boolean']
  end
  
  def update
  
    @context_configuration               = ContextConfiguration.find params[:id]
    @context_configuration.view_type     = params[:context_configuration][:view_type]
    @context_configuration.name          = params[:context_configuration][:name]
    @context_configuration.field_default = params[:context_configuration][:field_default]   
    @context_configuration.process_values(params[:values], params[:context_configuration][:values], params[:context_configuration][:view_type])

    #Add the old values
    if @context_configuration.values.empty?
       @context_configuration.values = params[:old_values].to_s
    else
      @context_configuration.values += ";" + params[:old_values].to_s
    end

    #VALID
    if @context_configuration.valid?
      
     #CHANGES
      #If field default change
      if @context_configuration.field_default_changed?
         #If now is TRUE
         if @context_configuration.field_default 
            @context_configuration.add_data_column_name
         #If now is FALSE
         else
           @context_configuration.delete_data_column_name
         end     
      #If field default NOT change and is TRUE, but the name change
      elsif @context_configuration.field_default and @context_configuration.name_changed?
         @context_configuration.modify_data_column_name   
      end#CHANGES  
      
    end #end VALID

    if @context_configuration.save and @context_configuration.errors.empty?
      redirect_to "/context_configurations"
    else
      @all_values = @context_configuration.values.split(";")
      @context_configuration.values = ""
      @view_types = ['checkbox','radiobutton','select','input','boolean']
      render "edit", :locals => {:context_configuration => @context_configuration} 
    end
    
end
 
  def disable
    @context_configuration = ContextConfiguration.find params[:id]
    @context_configuration.disable

    #if the configuration is default field, delete column in data set
     if @context_configuration.field_default
       #Delete the column of context_configuration.field_default
       circuits = Circuit.all
       circuits.each do |c|
             column_name = "default_" + @context_configuration.name
             c.delete_case_columns( column_name )
       end
     end

    redirect_to "/context_configurations"

  end


  #To get the user context configuration values for the Execution Pannel
  def user_context_configuration_values
    @user_configuration = UserConfiguration.find_by_user_id(current_user.id)
    @user_configuration_values = @user_configuration.get_hash_values
    @column_1, @column_2 = ContextConfiguration.calculate_columns   
    render :partial=>"execution_config_panel", :locals => {:user_configuration => @user_configuration,:user_configuration_values=>@user_configuration_values, :column_1=>@column_1, :column_2=>@column_2 }    
  end
  
end
