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
      params[:filter] = {} if !params[:filter]
      link_to per_page, suite_executions_path( { 'filter' => params[:filter].merge({:paginate=> per_page}) } )
    else
      per_page
    end
  end  
  
end
