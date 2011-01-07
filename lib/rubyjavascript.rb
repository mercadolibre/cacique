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
class Object
	
	def to_javascript_expr
		if instance_of? String then
			"\"#{javascript_escape(self)}\""
		elsif instance_of? Fixnum
			"#{self.to_s}"
		elsif instance_of? Array
			"[#{self.map{|x| x.to_javascript_expr }.join(",")}]"
		else
			raise "Cannot convert #{self}:#{self.class} to javascript"
		end
		
	end
	def to_javascript( nombre_variable )
		if instance_of? String then
			return "var #{nombre_variable} = \"#{javascript_escape(self)}\";\n"
		elsif instance_of? Fixnum
			return "var #{nombre_variable} = #{self.to_s};\n"
		elsif instance_of? Array
			return "var #{nombre_variable} = [#{self.map{|x| x.to_javascript_expr }.join(",")}];\n"
		elsif instance_of? Hash
			aux = "var #{nombre_variable} = new Array();\n"
			self.each do |key,value|
				aux = aux + "#{nombre_variable}[#{key.to_javascript_expr}] = #{value.to_javascript_expr};\n"
			end
			
			return aux
		else
			raise "Cannot convert #{self}:#{self.class} to javascript"
		end
		
	end
	
	def to_javascript_function( function_name )
		
		aux = "function #{function_name}() {\n"
		nombre_variable = "tmp"
		
		if instance_of? String then
			aux = aux +"var #{nombre_variable} = \"#{javascript_escape(self)}\";\n return #{nombre_variable};\n"
		elsif instance_of? Fixnum
			aux = aux + "var #{nombre_variable} = #{self.to_s};\n return #{nombre_variable};\n"
		elsif instance_of? Array
			aux = aux + "var #{nombre_variable} = [#{self.map{|x| x.to_javascript_expr }.join(",")}];\n return #{nombre_variable};\n"
		elsif instance_of? Hash
			aux = aux + "var #{nombre_variable} = new Array();\n"
			self.each do |key,value|
				aux = aux + "#{nombre_variable}[#{key.to_javascript_expr}] = #{value.to_javascript_expr};\n"
			end
			
			aux = aux +  "return #{nombre_variable};\n"
			
		else
			raise "Cannot convert #{self}:#{self.class} to javascript"
		end

		aux = aux + "}\n"
		return aux
	end
	
	def javascript_escape( str_ )
		
		str = str_.dup
		
		str.gsub!("\\","\\\\\\\\")
		str.gsub!("\"","\\\"")
		str.gsub!("\n","\\n")
		
		str
	end
end