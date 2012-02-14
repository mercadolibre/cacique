module SuiteExecutionsHelper

  def any_failed? average
    average[:failed] > 0? true: false
  end
  
  def average(suite_execution)
    status = suite_execution.executions.map(&:status)
    total = 0
    success = 0
    failed = 0
    status.each do |s|
      if s != 4
        if s == 2
          success += 1
        elsif s ==3
          failed += 1
        end
        total += 1
      end
    end
    if total == 0
	    ss = 0
	    ff = 0
    else
	    ss = success*100/total
	    ff = failed*100/total
    end
    {:success => (ss), :failed => (ff)}
  end


  # Returns an array with the suite's cases for a given circuit.
  def suite_cases(circuit,case_templates)
    cases = []
    case_templates.each {|template|cases << template if circuit.id == template.circuit_id}
    cases
  end

  def page_size_link per_page
    unless params[:per_page] == per_page.to_s
      index_path = params[:filter]? suite_executions_path( { 'filter' => params[:filter].merge({:paginate=> per_page}) } ) : suite_executions_path
      link_to per_page, index_path
    else
      per_page
    end
  end  
  
end
