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
  
end
