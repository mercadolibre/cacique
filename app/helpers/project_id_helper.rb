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
