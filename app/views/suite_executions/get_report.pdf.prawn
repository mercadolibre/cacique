pdf.font "Helvetica"

@executions.each do |u|
   pdf.text("#{u.suite.name}", :size => 16, :style => :bold, :spacing => 4, :align => :center) unless u.suite_id==0
   if u.status.to_i == 2
     pdf.fill_color "1c8201" #succes
   elsif u.status.to_i == 3 
     pdf.fill_color "f60510" #failure
   else
     pdf.fill_color "170858" #running, not run
   end

   pdf.move_down 10
   pdf.text "#{u.s_status}", :align=>:right
   pdf.move_up 13
   pdf.fill_color "000000"
   pdf.text "#{_('User:')}", :style => :bold
   pdf.text "#{u.user.name}"
   pdf.move_down 10
   unless u.suite_id==0
     pdf.text "Suite:", :style => :bold
     pdf.text "#{u.suite.name}"
     pdf.text "#{_('Description:')}",:style => :bold
     pdf.text "#{u.suite.description.capitalize}"
   end
   unless (u.identifier.nil? || u.identifier.empty?)
     pdf.move_down 10
     pdf.text "#{_('Identifier:')}", :style => :bold
     pdf.text "#{u.identifier}"
   end
   pdf.move_down 10
   pdf.text "#{_('Run Start:')}",:style => :bold
   pdf.text "#{u.created_at.strftime('%Y/%m/%d %H:%M:%S')}" 
   pdf.move_down 20
   pdf.text "#{_('Executions:')}",:style => :bold
   u.executions.each do |exe|
     pdf.y=pdf.y-13
     
     if exe.status.to_i == 2
       pdf.fill_color "1c8201" #succes
     elsif u.status.to_i == 3
       pdf.fill_color "f60510" #failure
     else
       pdf.fill_color "170858" #running, not run
     end

     pdf.text "-", :size => 42
     pdf.fill_color "000000"
     pdf.y=pdf.y-4
     pdf.draw_text "Script: #{exe.circuit.name}", :at => [40,pdf.y] 
     pdf.y=pdf.y-15
     pdf.draw_text "Objetivo del caso: #{exe.case_template.objective}", :at => [40,pdf.y] if exe.case_template
     pdf.y=pdf.y-15
     pdf.move_down 10
   end
   pdf.start_new_page
end
