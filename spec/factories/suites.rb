Factory.define :suite do |s|
  s.add_attribute :name, "test" 
  s.add_attribute :description, "test" 
  s.association   :project_id, :factory => :project
end
