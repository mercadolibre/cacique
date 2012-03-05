module SuiteExecutionsHelper

  def any_failed? average
    average[:failed] > 0? true: false
  end
  
  # Returns an array with the suite's cases for a given circuit.
  def suite_cases(circuit,case_templates)
    cases = []
    case_templates.each {|template|cases << template if circuit.id == template.circuit_id}
    cases
  end

  def page_size_link per_page
    unless params[:per_page] == per_page.to_s
      params_aux = {:paginate=> per_page, :kind=>params[:kind]}
      params_aux = params_aux.merge({'filter' => params[:filter]}) if params[:filter]
      link_to per_page, suite_executions_path(params_aux)
    else
      per_page
    end
  end  
  
end
