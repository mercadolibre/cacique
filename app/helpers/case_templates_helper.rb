module CaseTemplatesHelper
  def page_size_link per_page
    unless params[:per_page] == per_page.to_s
      link_to per_page, project_circuit_case_templates_path(@circuit.project_id, @circuit, {:per_page => per_page, :case_templates => {:objective=>@search_case}})
    else
      per_page
    end
  end
end