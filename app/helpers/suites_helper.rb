module SuitesHelper

  # Returns an array with the suite's cases for a given circuit.
  def suite_cases(circuit,case_templates)
    cases = []
    case_templates.each {|template|cases << template if circuit.id == template.circuit_id}
    cases
  end



  # Returns true if the case template belongs to the given suite.
  def case_in_suite?(case_template,suite)
    [case_template]&(suite.case_templates) != []
  end

end
