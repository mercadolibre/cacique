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
class SuiteCasesRunnerDb

	attr_accessor	:execution_id

	def get_relations_args(case_template_id)

		execution = Execution.find(execution_id)
		suite_execution = SuiteExecution.find(execution.suite_execution_id)
		suite_id = suite_execution.suite_id

		father = SuiteCasesRelation.find(:all, :conditions  => [ "case_destination = ? and suite_id = ?", case_template_id, suite_id ] )

		retorno = Hash.new

		father.each do |f|
			case_origin = f.case_origin

			# Find execution for suite_execution & case
			father_execution = suite_execution.executions.find(:last, :conditions => [ "case_template_id = ?", case_origin] )

			circuit_origin = Circuit.find( father_execution.circuit_id )

			# Find fields relations for relation
			field_relations = SuiteFieldsRelation.find(:all, :conditions => [ "circuit_origin_id = ? AND circuit_destination_id = ?", father_execution.circuit_id, execution.circuit_id] )

			 raise "El caso Padre #{f.case_origin} dio error y por eso no se ejecuta." if father_execution.status == 3 and father_execution.status != 4
			# recorrer los data_recoveries de esa execution
			father_execution.data_recoveries.each do |datarec|
				# Verify if data_recovery have field_relation

				field_relations.each{ |fr|
					if datarec.data_name ==  fr.field_origin
						print "load parameter #{fr.field_destination} = #{datarec.data}\n"
						retorno[fr.field_destination.to_sym] = datarec.data
					end
				}
			end
		end

		return retorno
	end
	
	#Added the method to avoid errors in retry to execute run_execution
	def process_return_values(id, forward_rels, args, devuelve)
	end
end

