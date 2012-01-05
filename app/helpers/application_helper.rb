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
# Methods added to this helper will be available to all templates in the application.
require "lib/rubyjavascript.rb"
#include FastGettext::Translation

module ApplicationHelper

  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end

end

  def escape_html_attribute( str_ )
    str = str_.dup

    str.gsub!("\\","\\\\\\\\")
    str.gsub!("'","")
    str.gsub!("\"","")
    str.gsub!("\n","")
    str.gsub!("\r","")
    str.gsub!("\t","")
    "'#{str}'"
  end


  def get_view_names()
     view, view_category, view_executions, view_suites, view_categories = Hash.new
     view = {"home_cacique:index"=>"Home", "categories:index"=>"Scripts", "suites:index"=>"Suites", "suite_executions:index"=>_("Suite Execution History"),"case_templates:index"=>_("Data Set"), "admin:index"=>"Admin"}
     view_circuits   = {"circuits:edit"=>_("Script Edit"), "circuits:new"=>_("Script Create"), "circuits:rename"=>_("Script Create"), "circuits:rename_save"=>_("Script Create")}
     view_categories = {"categories:import_circuit"=>_("Import Scripts"), "categories:new"=>_("Create Folder")}
     view_executions = {"executions:show"=>_("Unit Execution"), "suite_executions:show"=>_("Suite Execution"), "case_templates:show"=>_("Unit Execution History")}
     view_suites     =  {"suites:edit"=>_("Edit Suite"), "suites:show"=>_("Suite Details"), "suites:relations1"=>_("Suite - Script Relations"), "suites:relations2"=>_("Suite - Field Relations"), "suites:relations3"=>_("Suite - Cases Relations"),"suites:import_suite"=>_("Import Suite"), "suite_executions:suite_comment"=>_("Comment Cases"), "suite_executions:new"=>_("Suites Execution Pannel")}
     view.merge!(view_circuits)
     view.merge!(view_executions)
     view.merge!(view_suites)
     view.merge!(view_categories)
     view
  end
#------------------------------CATEGORIES TREE-----------------------------


def category_tree(item_list, view)
 list = item_list.sort_by { |x| x.name.downcase }
  case view
    when 'index'
      list_children_index(list)
    when 'import_circuit'
      list_project(list, 'circuit')
    when 'move'
      list_children_move(list)
    when 'suite'
      list_children_suite(list)
    when 'import_suite'
      list_project(list, 'suite') 
  end
end


#Node Parameters: (id, pid, name, url, title, target, icon, iconOpen, open)
#NOTE: Tree is built with categories and circuits IDS.


   #Category Index (Selección de categorías o circuitos por javascript)
   def list_children_index(categories)
   ret = ""
      unless categories.empty? || categories.nil?
        categories.each do |category|
           #have parent
           if category.parent
                aux_html = "<c id =#{category.id}   name='category' title=#{h(category.description) } >#{truncate(h(category.name), :length =>25)}</c>"
                ret += "d.add( "+ category.id.to_s + "," + category.parent_id.to_s + ", #{aux_html.to_javascript_expr} ,'', '', '', '/images/dtree/folder.gif');"
                #Scripts
                category.active_circuits.each do |circuit|
                   aux_html = "<c id= #{circuit.id}  name='script' title='#{h(circuit.description)}' >#{truncate(h(circuit.name), :length =>25)} </c>"
                   aux_url  = edit_project_circuit_path(circuit.project_id,circuit)
                   ret += "d.add('#{category.id.to_s}.#{circuit.id.to_s}'," + category.id.to_s + ", #{aux_html.to_javascript_expr},'" + aux_url + "');"
                 end
           else
              #main category
              aux_html = "<c id =#{category.id}   name='category' title=#{h(category.description)} >#{truncate(h(category.name), :length =>25)}</c>"
              ret += "d.add(" + category.id.to_s + ",0,#{aux_html.to_javascript_expr} ,'', '', '', '/images/dtree/folder.gif');"
               #Scripts
              category.active_circuits.each do |circuit|
                   aux_html = "<c id= #{circuit.id} name='script' title='#{h(circuit.description)}' >#{truncate(h(circuit.name), :length =>25)} </c>"
                   aux_url = edit_project_circuit_path(circuit.project_id,circuit)
                   ret += "d.add('#{category.id.to_s}.#{circuit.id.to_s}',#{category.id.to_s},#{aux_html.to_javascript_expr},'" + aux_url + "');"
               end
           end
           childrens = category.children.sort_by { |x| x.name.downcase }
           ret += list_children_index(childrens)
        end
      end
      ret
   end

   # Category Move (checkbox scripts)
   def list_children_move(categories)
   ret = ""
      unless categories.empty? || categories.nil?
        categories.each do |category|
           #have parent
           if category.parent
                aux_html = "<c title=#{escape_html_attribute(category.description)}>#{truncate(h(category.name), :length =>60)}</c>"
                ret += "d.add( "+ category.id.to_javascript_expr + "," + category.parent_id.to_javascript_expr + ",#{aux_html.to_javascript_expr},'', '', '', '/images/dtree/folder.gif');"
                #Scripts
                category.active_circuits.each do |circuit|
                   aux_html = "<c title=#{escape_html_attribute(circuit.description)}>#{truncate(h(circuit.name), :length =>60)}</c><input type='checkbox' name=circuits_ids[] value=#{circuit.id}> "
                   ret += "d.add('#{category.id.to_s}.#{circuit.id.to_s}'," + category.id.to_javascript_expr + ",#{aux_html.to_javascript_expr});"
                 end
           else
              #main category
               aux_html = "<c  title=#{escape_html_attribute(category.description)}>#{truncate(h(category.name), :length =>60)}</c>"
              ret += "d.add(" + category.id.to_javascript_expr + ",0,#{aux_html.to_javascript_expr} ,'', '', '', '/images/dtree/folder.gif');"
              #Scripts
              category.active_circuits.each do |circuit|
                 aux_html = "<c title=#{escape_html_attribute(circuit.description)}>#{truncate(h(circuit.name), :length =>60)}</c><input type='checkbox' name=circuits_ids[] value=#{circuit.id}> "
                 ret += "d.add('#{category.id.to_s}.#{circuit.id.to_s}'," + category.id.to_javascript_expr + ",#{aux_html.to_javascript_expr});"
               end
           end
           childrens = category.children.sort_by { |x| x.name.downcase }
           ret += list_children_move(childrens)
        end
      end
      ret
   end

    # Category Import (projects checkbox script)
   def list_children_import(categories)
   ret = ""
      unless categories.empty? || categories.nil?
        categories.each do |category|
           #have parent
           if category.parent
                aux_html = "<c title=#{escape_html_attribute(category.description)}>#{truncate(h(category.name), :length =>60)}</c>"
                ret += "d.add( '#{category.project_id.to_s}.#{category.id.to_s}', '#{category.project_id.to_s}.#{category.parent_id.to_s}',#{aux_html.to_javascript_expr},'', '', '', '/images/dtree/folder.gif');"
                #Scripts
                category.active_circuits.each do |circuit|
                  aux_html = "<c title=#{escape_html_attribute(circuit.description)}>#{truncate(h(circuit.name), :length =>60)}</c><input type='checkbox' name=circuits_ids[] value=#{circuit.id}> "
                  ret += "d.add( '#{category.project_id.to_s}.#{category.id.to_s}.#{circuit.id.to_s}','#{category.project_id.to_s}.#{category.id.to_s}',#{aux_html.to_javascript_expr});"
                end
           else
              #main category
              aux_html = "<c  title=#{escape_html_attribute(category.description)}>#{truncate(h(category.name), :length =>60)}</c>"
              ret += "d.add('#{category.project_id.to_s}.#{category.id.to_s}','#{category.project_id.to_s}',#{aux_html.to_javascript_expr} ,'', '', '', '/images/dtree/folder.gif');"
              #Scripts
              category.active_circuits.each do |circuit|
                aux_html = "<c title=#{escape_html_attribute(circuit.description)}>#{truncate(h(circuit.name), :length =>60)}</c><input type='checkbox' name=circuits_ids[] value=#{circuit.id}> "
                ret += "d.add( '#{category.project_id.to_s}.#{category.id.to_s}.#{circuit.id.to_s}','#{category.project_id.to_s}.#{category.id.to_s}',#{aux_html.to_javascript_expr});"
              end
           end
           childrens = category.children.sort_by { |x| x.name.downcase }
           ret += list_children_import(childrens)
        end
      end
      ret
   end


    # Category Import (project cagory list) or Suite Import (project suite list)
   def list_project(projects, type_import)
     ret = ""
      unless projects.empty? || projects.nil?
        projects.each do |project|
           aux_html = "<c id ='#{project.id.to_s}' title=#{escape_html_attribute(project.description.to_s)}>#{truncate(h(project.name.to_s), :length =>60)}</c>"
           ret += "d.add(#{project.id.to_s},0,#{aux_html.to_javascript_expr},'', '', '', '/images/dtree/base.gif', '/images/dtree/baseopen.gif');"
           if type_import == 'circuit'
              categories = (project.categories.find_all_by_parent_id "0").sort_by { |x| x.name.downcase }
              ret += list_children_import(categories)
           elsif type_import == 'suite'
              suites = (project.suites.sort_by{ |x| x.name.downcase })
              ret += list_children_import_suite(suites,project.id)
           end
        end
        
          
      end
      ret
   end



   # Suite edit (Checkbox scripts. Check added scripts)
   def list_children_suite(categories)
   ret = ""
      unless categories.empty? || categories.nil?
        categories.each do |category|
           #have paret
           if category.parent
                aux_html = "<c title=#{escape_html_attribute(category.description)}>#{truncate(h(category.name), :length =>60)}</c>"
                ret += "d.add( "+ category.id.to_javascript_expr + "," + category.parent_id.to_javascript_expr + ",#{aux_html.to_javascript_expr},'', '', '', '/images/dtree/folder.gif');"
                #Scripts
                category.active_circuits.each do |circuit|
                  #In method "onclick" call is made by ajax to add to the suite scrpt. Also in the parameter "onComplete" method calls another "remote_function" to refresh the suite editor divs: order the scripts and the addition of cases.
                  aux_html = "<c title=#{escape_html_attribute(circuit.description)}>#{truncate(h(circuit.name), :length =>60)}</c><input type='checkbox' name=circuits_ids[] value=#{circuit.id} #{'checked' if script_checked(circuit, @suite) } onclick=\"if(tree_with_ajax){new Ajax.Updater('suite_circuits', '/suites/update_circuit/#{@suite.id}', {asynchronous:true, evalScripts:true, method:'get', parameters:'circuit_id=#{circuit.id}', onComplete: function(request){new Ajax.Updater('suite_circuits_order', '/suites/update_circuits_order/#{@suite.id}', {asynchronous:true, evalScripts:true, method:'get' })} })}\"> "
                  ret += "d.add('#{category.id.to_s}.#{circuit.id.to_s}'," + category.id.to_javascript_expr + ",#{aux_html.to_javascript_expr});"
                end
           else
              #main category
               aux_html = "<c  title=#{escape_html_attribute(category.description)}>#{truncate(h(category.name), :length =>60)}</c>"
              ret += "d.add(" + category.id.to_javascript_expr + ",0,#{aux_html.to_javascript_expr} ,'', '', '', '/images/dtree/folder.gif');"
              #Scripts
              category.active_circuits.each do |circuit|
                #In method "onclick" call is made by ajax to add to the suite scrpt. Also in the parameter "onComplete" method calls another "remote_function" to refresh the suite editor divs: order the scripts and the addition of cases.
                aux_html = "<c title=#{escape_html_attribute(circuit.description)}>#{truncate(h(circuit.name), :length =>60)}</c><input type='checkbox' name=circuits_ids[] value=#{circuit.id} #{'checked' if script_checked(circuit, @suite) } onclick=\"if(tree_with_ajax){new Ajax.Updater('suite_circuits', '/suites/update_circuit/#{@suite.id}', {asynchronous:true, evalScripts:true, method:'get', parameters:'circuit_id=#{circuit.id}', onComplete: function(request){new Ajax.Updater('suite_circuits_order', '/suites/update_circuits_order/#{@suite.id}', {asynchronous:true, evalScripts:true, method:'get' })} })}\"> "
                ret += "d.add('#{category.id.to_s}.#{circuit.id.to_s}'," + category.id.to_javascript_expr + ",#{aux_html.to_javascript_expr});"
              end
           end
           childrens = category.children.sort_by { |x| x.name.downcase }
           ret += list_children_suite(childrens)
        end
      end
      ret
   end
   
   #all suites with import checkbox
   def list_children_import_suite(suites,project_id)
    ret = ""
      unless suites.empty? || suites.nil?
        suites.each do |suite|
          aux_html = "<c title=#{escape_html_attribute(suite.description)}>#{truncate(h(suite.name), :length =>90)}</c><input type='checkbox' name=suites_ids[] value=#{suite.id}  > "
          ret += "d.add('#{project_id}.#{suite.id.to_javascript_expr}'," + project_id.to_s + ",#{aux_html.to_javascript_expr});"
        end
      end
    ret
   end

#Knowing if a script is in a suite, if suite != nill
   def script_checked(circuit,suite)
      if !suite.nil?
        if !@suite.circuits.nil?
          return !@suite.circuits.select{|q| q.id == circuit.id}.empty?
        end
      else
        return false
      end
   end
