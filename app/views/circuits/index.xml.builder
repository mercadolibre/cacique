xml.instruct!
xml.comment! "This xml conains information about categories and scripts on cacique"
xml.project @project_actual.name, :id => @project_actual.id

cats=@project_actual.categories
cats.each do |cat|
  xml.categories do 
    xml.category_name cat.name, :id=> cat.id, :description => cat.description  
    xml.circuits do 
      cat.circuits.each do |circuit|
        xml.circuit circuit.name, :id=>circuit.name, :description=> circuit.description    
      end
    end
  end
end
