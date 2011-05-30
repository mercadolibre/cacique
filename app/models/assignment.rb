class Assignment < ActiveRecord::Base
 belongs_to :project
 validates_uniqueness_of :project_id, :scope => :user_id , :message => _('User is already assigned to the project')   


end
