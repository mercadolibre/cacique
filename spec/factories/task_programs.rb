Factory.define :task_program do |tp|
  tp.add_attribute :user_id, 1
  tp.add_attribute :suite_execution_ids, ""
  tp.association   :suite_id, :factory => :suite
  tp.association   :project_id, :factory => :project
end
