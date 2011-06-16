xml.instruct!
xml.comment! "This xml conains information about scripts for cacique"
xml.circuit  do
  xml.id @circuit.id
  xml.readonly @readonly
  xml.name @circuit.name
  xml.project @circuit.project.name
  xml.description @circuit.description
  xml.category_id @circuit.category_id
  xml.source_code @circuit.source_code
  xml.user do
     xml.id @circuit.user.id
     xml.login @circuit.user.login
     xml.name  @circuit.user.name
  end
  xml.created_at @circuit.created_at
  xml.updated_at @circuit.updated_at
  xml.versions do 
    xml.previous @previous_version if @previous_version 
    xml.next @next_version if @next_version 
  end
end
