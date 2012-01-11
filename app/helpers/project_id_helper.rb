# Methods added to this helper will be available to all templates in the application.
module ProjectIdHelper


	class ProjectIdHashWrapper
		def initialize( wrapped, project_id )
			@wrapped = wrapped
			@project_id = project_id
		end
		
		def [] (index)
			if index.to_sym == :project_id
				@project_id
			else
				@wrapped[index]
			end
		end
		
		def clone
			ProjectIdHashWrapper.new( @wrapped.clone, @project_id)
		end
		
		def method_missing(m,*args)
			@wrapped.send(m,*args)
		end
			
	end

	def get_project_id
		internal_get_project_id( params["project_id"] )
	end
	
	def set_project_id( project_id )
		cookies["project_id"] = project_id
	end
	
	def params
		project_id = internal_get_project_id( super[:project_id] )
		ProjectIdHashWrapper.new(super, project_id)
	end

private
	def internal_get_project_id( param )
		project_id = param || request.cookies["project_id"]
		cookies["project_id"] = param if param
		return project_id
	end
end
