pdf.font "Helvetica"

@suite_executions.each do |suite_execution|

  pdf.move_down 10
  #Line
  pdf.stroke do
    pdf.horizontal_rule
  end
  pdf.move_down 10

  #Name: verifies the name of the suite, or if an execution unit, the script
  entity = (suite_execution.suite_id==0)? suite_execution.executions.first.circuit : suite_execution.suite 
  pdf.text "#{entity.name}", :styles => [:bold], :size => 20

  #Status
  case suite_execution.status.to_i
    when 2
      color = "1c8201" #succes
    when 3 
      color = "f60510" #failure
    else
      color = "170858" #running, not run
    end
  pdf.text "<color rgb='#{color}'> #{suite_execution.s_status} </color>", :inline_format => true, :styles => [:bold], :size => 15

  pdf.move_down 10
  #Line
  pdf.stroke do
    pdf.horizontal_rule
  end
  pdf.move_down 10

  %w[b].each do |tag|

    #Identifier
    unless (suite_execution.identifier || suite_execution.identifier.empty?)
      pdf.text "<#{tag}>#{_('Identifier:')}</#{tag}> #{suite_execution.identifier} ", :inline_format => true
    end

    #User
    pdf.text "<#{tag}>#{_('User:')}</#{tag}> #{suite_execution.user.name} ", :inline_format => true

    #Date
    pdf.text "<#{tag}>#{_('Run Start:')}</#{tag}> #{suite_execution.created_at.strftime('%Y/%m/%d %H:%M:%S')}", :inline_format => true

    pdf.move_down 10
    #Execution configuration
    @run_configurations[suite_execution.id].each do |conf|
      if conf.context_configuration.view_type == 'boolean'
        if conf.value == '1'
          pdf.text "<#{tag}>#{conf.context_configuration.name.capitalize}: </#{tag}> True",:inline_format => true
        else
          pdf.text "<#{tag}>#{conf.context_configuration.name.capitalize}: </#{tag}> False",:inline_format => true
        end
      else
        pdf.text "<#{tag}>#{conf.context_configuration.name.capitalize}: </#{tag}> #{conf.value}",:inline_format => true
      end
    end

  end

  pdf.move_down 10

  pdf.text "#{_('Executions:')}",:style => :bold
  #Executions
  suite_execution.executions.each do |exe|
     
    #Status
    case exe.status.to_i
      when 2
        status_color = "1c8201" #succes
      when 3
        status_color = "f60510" #failure
      else
        status_color = "170858" #running, not run
    end

    #Name & objective
    execution_text =   "#{exe.circuit.name}"
    execution_text +=  ": #{exe.case_template.objective}" if exe.case_template
    pdf.text "<color rgb='#{status_color}'><font size='25'> -</font> </color> #{execution_text} ",:inline_format => true,:styles => [:bold]
  end

  pdf.start_new_page

end
