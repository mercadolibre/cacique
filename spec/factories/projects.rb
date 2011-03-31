Factory.define :project do |p|
  p.add_attribute :name, "test"
  p.add_attribute :description, "test" 
  p.association   :user_id, :factory => :user
end
