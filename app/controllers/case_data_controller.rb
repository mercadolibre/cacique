class CaseDataController < ApplicationController

  def update
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

end
