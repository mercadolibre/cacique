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


class CategoriesController < ApplicationController

  before_filter :load_categories, :only => [:show_categories, :create, :update, :delete]

  def show_categories
      render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => nil}
  end

  def load_categories
    @project = Project.find params[:project_id]
    permit "viewer of :project" do
      @categories = @project.categories.find_all_by_parent_id "0"
    end
  end

  def move
      #Formato: categori_name  => category.id
      @categories_to = Hash.new
      @project =  Project.find(params[:project_id])
      permit "editor of :project" do
	      @categories =  @project.all_cached_categories
	      @categories.each do |category|
		       @categories_to[category.name] = category.id
	      end
	    end
      @categories = @project.categories.find_all_by_parent_id "0"
      @categories_to = @categories_to.sort_by{ |x| x[0].downcase }
  end

  def move_save

     @category_to = params[:category_to]
     @category_to_ = Category.find( @category_to )

     permit "editor of :category_to_" do

	    params[:circuits_ids].each do |circuit|
	      @circuit_to_move = Circuit.find circuit.to_i

	        @category_from_ = @circuit_to_move.category
		    permit "editor of :category_from_" do

		      #modify parent Id
		      @circuit_to_move.category_id = @category_to
		      @circuit_to_move.save
		    end
	    end
	    redirect_to "/circuits"
     end
  end


  def edit
	  category_id = params[:category_id]
	  @category = Category.find(category_id)
    if current_user.has_role?("editor", @project)
	     @project_id = params[:project_id]
    else
       text_error = [_('Impossible to edit ')+"- "+_('You do not have Edit Permissions')]
       render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => text_error}
    end
    render :partial => "edit", :locals => {:category => @category}
  end
  

  def update
	 @category = Category.find params[:id]
   if  current_user.has_role?( "editor", @project)
		  @category.name = params[:name]
		  @category.description = params[:description]
		  if @category.save
		    if @category.parent_id == 0
		      #refres parent category in before_filter
		      @categories = @project.categories.find_all_by_parent_id "0"
		    end
            render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => nil} 
          else

            text_error = Array.new
            text_error << _("Impossible to modify ")+"#{@category.name_was}"
            @category.errors.full_messages.each {|error|  text_error << error}
            render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => text_error}
	      end
    else

        text_error = [_("Impossible to edit ")+"- "+_("You do not have Edit Permissions")]
        render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => text_error}
    end
  end


  def delete
	  @category = Category.find(params[:category_id]) 
   if  current_user.has_role?( "editor", @project)
		if @category.can_delete?
		   	@category.destroy
		   	if @category.parent_id == 0
		   	  #refres parent category in before_filter
		      @categories = @project.categories.find_all_by_parent_id "0"
		   	end
            render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => nil}
	  	else
         text_error = _("ERROR: Can´t delete folder: ")+"'#{@category.name}'."+_(" Folder is not empty.")
         render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => text_error}
       end
    else
        text_error = [_("Impossible to delete ")+"- "+_("You do not have Edit Permissions")]
        render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => text_error}     
    end
  end

  def create
      if  current_user.has_role?( "editor", @project)
		    @category = Category.create(:name=>params[:name], :description=>params[:description], :parent_id=>params[:parent_id], :project_id=>params[:project_id])
		    if @category.save
		      if params[:parent_id] == "0"
		        #if is a New category without parent, must refresh parent categories in before_filter
		        @categories = @project.categories.find_all_by_parent_id "0"
		      end
                      render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => nil}
		    else
                       text_error = Array.new
                       text_error << _("Impossible to create ")+"#{@category.name_was}"
                       @category.errors.full_messages.each {|error|  text_error << error}
                       render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => text_error}
		    end
      else
            text_error = [_("Impossible to create ")+"- "+_("You do not have Edit Permissions")]
            render :partial => "categories/tree_menu", :locals => { :categories=> @categories, :project=> @project, :text_error => text_error}
      end
  end

  def import_circuit
    @projects = Project.find :all, :order=>"name ASC"
    @project = Project.find params[:project_id]
    permit "editor of :project" do
      @projects = @projects - @project.to_a
    end
  end


  def save_import_circuit
    if params.include?(:project)
      @project = Project.find params[:project][:id]
    else
      @project = Project.find params[:project_id]
    end
    #Search Draft Category. If not exist, is created
    import_folder = _("Imported")
    @category = @project.categories.find_by_name(import_folder)
    
    if @category.nil?
	   @category = Category.new
	   @category.name = import_folder
	   @category.description = _("folder where you saved the script imported")
	   @category.parent_id = 0
	   @category.project_id = @project.id
	   @category.save
   end

    #permision verify and copy my scripts to @category
    @category.import_circuits(@project, params[:circuits_ids], params[:cases])
    redirect_to project_circuits_path(@project.id)
  end

  def search_circuit
  end

  def circuits_result
    @results=Circuit.get_all(params[:search_pattern])
    @pag = @results.paginate :page => params[:page], :per_page => 10
  end

end
