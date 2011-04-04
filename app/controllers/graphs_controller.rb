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


class GraphsController < ApplicationController

  def index
    permit "root" do
        @tot_suites = Suite.all.count
        @tot_scripts = Circuit.all.count
        @years = (Time.now.year - 2)..Time.now.year
    end
  end

  def graph
    if params[:year].first != ""
      @graph = open_flash_chart_object(800,500, "/graphs/show_graph?year=#{params[:year].first}&view=#{params[:view]}")
      render :loyout=>false
    else
      render :nothing => true
    end
  end

  def show_graph

    line_data = Hash.new
    values_1 = Array.new
    values_2 = Array.new
    year = params[:year]
    view = params[:view]

#data to view
case view
	when _("Executions"):
         #Executions
         reg_1  = SuiteExecution.find_by_sql "SELECT WEEK(created_at) AS \"week\", concat(day(created_at),\"/\",month(created_at), \";\", count(id))  AS \"count\"  FROM suite_executions where  year(created_at) = #{year}  and suite_id = 0 GROUP BY WEEK(created_at);"
         reg_2  = SuiteExecution.find_by_sql "SELECT WEEK(created_at) AS \"week\", concat(day(created_at),\"/\",month(created_at), \";\", count(id))  AS \"count\"  FROM suite_executions where  year(created_at) = #{year}  and suite_id != 0 GROUP BY WEEK(created_at);"
         tot_executions = SuiteExecution.count_by_sql "SELECT count(id)  FROM suite_executions where year(created_at) = #{year}  and suite_id = 0"
         tot_suites_executions = SuiteExecution.count_by_sql "SELECT count(id) FROM suite_executions where year(created_at) = #{year}  and suite_id != 0"
         name1 = _("Unit:")+" #{tot_executions}"
         name2 = "Suites: #{tot_suites_executions}"

	when "Scripts":
         #Scripts
         reg_1  = Circuit.find_by_sql "SELECT WEEK(created_at) AS \"week\", concat(day(created_at),\"/\",month(created_at), \";\", count(id))  AS \"count\"  FROM circuits where  year(created_at) = #{year} GROUP BY WEEK(created_at);"
         reg_2  = Suite.find_by_sql "SELECT WEEK(created_at) AS \"week\", concat(day(created_at),\"/\",month(created_at), \";\", count(id))  AS \"count\"  FROM  suites    where  year(created_at) = #{year} GROUP BY WEEK(created_at);"
         tot_circuits = Circuit.count_by_sql "SELECT count(id)  FROM circuits where year(created_at) = #{year}"
         tot_suites   = Suite.count_by_sql "SELECT count(id) FROM suites where year(created_at) = #{year}"
         name1 = "Scripts: #{tot_circuits}"
         name2 = "Suites: #{tot_suites}"

	else
         #Executions
         reg_1  = SuiteExecution.find_by_sql "SELECT WEEK(created_at) AS \"week\", concat(day(created_at),\"/\",month(created_at), \";\", count(id))  AS \"count\"  FROM suite_executions where  year(created_at) = #{year}  and suite_id = 0 GROUP BY WEEK(created_at);"
         reg_2  = SuiteExecution.find_by_sql "SELECT WEEK(created_at) AS \"week\", concat(day(created_at),\"/\",month(created_at), \";\", count(id))  AS \"count\"  FROM suite_executions where  year(created_at) = #{year}  and suite_id != 0 GROUP BY WEEK(created_at);"
         tot_executions = SuiteExecution.count_by_sql "SELECT count(id)  FROM suite_executions            where year(created_at) = #{year}  and suite_id = 0"
         tot_suites_executions = SuiteExecution.count_by_sql "SELECT count(id) FROM suite_executions where year(created_at) = #{year}  and suite_id != 0"
         name1 = _("Unit:")+" #{tot_executions}"
         name2 = "Suites: #{tot_suites_executions}"
  end

    #If no data
    if (reg_1.empty? and reg_2.empty?)
       render :text => "Without data"
    else
      values_1, values_2, labels = gen_data(reg_1, reg_2)
      #urls values
      line_data[name1] =  values_1
      line_data[name2] =  values_2

      #Y Range
      value_range = get_value_range(values_1,values_2.count )

      # Graph
      chart = line_graph(view.capitalize + " (#{year})", _("Weeks"), _("Quantity"), line_data, value_range,[1,values_1.count,1],labels)

      render :text => chart.to_s
    end
  end

  def gen_data(reg_values1, reg_values2)

    values1   = Array.new
    values2   = Array.new
    labels    = Array.new

    #days without values
    weeks_values1  = Hash.new
    weeks_values2  = Hash.new
    hash_labels   = Hash.new

    #max week 
    cant_weeks = [reg_values1.map(&:week).collect{|x| x.to_i}.max , reg_values2.map(&:week).collect{|x| x.to_i}.max].max

    #values
    i = 1
    1..cant_weeks.times {weeks_values1[i] = 0; i=i+1}
    i = 1
    1..cant_weeks.times {weeks_values2[i] = 0; i=i+1}
    i = 1
    1..cant_weeks.times {hash_labels[i] = ""; i=i+1}

    # complete Labels with registries values
    reg_values1.each do |reg1|
      weeks_values1[reg1.week.to_i] = reg1.count.split(';')[1].to_i
      hash_labels[reg1.week.to_i]   = reg1.count.split(';')[0]
    end

    #Register2 values complete
    reg_values2.each do |reg2|
      weeks_values2[reg2.week.to_i] = reg2.count.split(';')[1].to_i
      hash_labels[reg2.week.to_i]   = reg2.count.split(';')[0]
    end



    # sort values
    weeks_values1.keys.sort.each{|k|  values1<<  weeks_values1[k]}
    weeks_values2.keys.sort.each{|k|  values2<<  weeks_values2[k]}

    #sort labels
    hash_labels.keys.sort.each{|k|  labels<<  hash_labels[k]}

    return values1, values2,labels

  end


    #line graph
  def line_graph(title_graph, title_x, title_y, lines_data, range_y, range_x,label_range)

    #Color lines
    color_lines = [ '#380B6', '#FE9A2E','#380B61', '#DF74011','#DFC329', '#088A08']
    lines = Array.new

    #Data Format: {line1=>[data1,data2...], line2=>[data1,data2...]}
    i = 0
    lines_data.each_pair do |name, data|
      line = Line.new
      line.text = name
      line.width = 3
      line.colour = color_lines[i]
      line.dot_size = 4
      line.values = data
      lines << line
      (i == color_lines.length)?i = 0 : i = i +1
    end

    y = YAxis.new
    #Y Axis Range (Init, End, Range)
    y.set_range(range_y[0],range_y[1],range_y[2])

    x = XAxis.new
    #X Axis Range (Init, End, Range)
    x.set_range(range_x[0],range_x[1],range_x[2])

    i = 1
    all_labels = []
      labels = XAxisLabels.new
      labels.text = ''
      labels.steps = 0
      labels.visible_steps = range_x[1]
      labels.rotate = 90
      all_labels << labels

    label_range.each do |text|
      labels = XAxisLabels.new
      labels.text = text
      labels.steps = i
      labels.visible_steps = range_x[1]
      labels.rotate = 90
      all_labels << labels
      i = i + 1
    end
      x.labels = all_labels

    y_legend = YLegend.new(title_y)
    y_legend.set_style('{font-size: 14px; color: #4F5DD5}')
    x_legend = XLegend.new(title_x)
    x_legend.set_style('{font-size: 14px; color: #4F5DD5}')
    title = Title.new(title_graph)
    title.set_style('{font-size: 14px; color: #293484}')

    chart =OpenFlashChart.new
    chart.set_title(title)
    chart.set_x_legend(x_legend)
    chart.set_y_legend(y_legend)
    chart.y_axis = y
    chart.x_axis = x

    #add Lines
    lines.each do |li|
       chart.add_element(li)
    end
    chart
  end

  #
  #Gets the range that should be displayed for the y-axis
  def get_value_range(values, cant)
    #The range is assembled according to the values obtained
    max_x     = (values).max
    #
    #rounded up. Ej: 4563 => 50000
    max_x     = ( max_x.to_i / 10 ** (max_x.to_i.to_s.length - 1) ) * 10 ** (max_x.to_i.to_s.length - 1)
    max_x     =  max_x + ( (10 **(max_x.to_i.to_s.length - 1)) * 2)  
    interbalo = ( max_x / cant) * 2
    interbalo = ( interbalo.to_i / 10 ** (interbalo.to_i.to_s.length - 1) ) * 10 ** (interbalo.to_i.to_s.length - 1)

    #No values for date
    if(interbalo == 0)
      interbalo = 5
      max_x = 5
    end

    [0,max_x.to_i,interbalo.to_i]
  end

end

