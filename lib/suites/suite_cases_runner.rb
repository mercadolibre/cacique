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
class SuiteCasesRunner

	class ForwardRel

		attr_accessor	:circuito_destino
		attr_accessor	:fields

		def initialize( circuito_destino,  fields )
			@circuito_destino = circuito_destino
			@fields = fields
		end
	end

	class RelRunData
		attr_accessor	:fields
		attr_accessor	:error

		def initialize
			@fields = Hash.new
		end
	end

#	attr_accessor	:circuit_runner

	def initialize( )
#		@circuit_runner = circuit_runner
		@rel_run_data = Hash.new
	end

	def process_return_values(id, forward_rels, args, devuelve)
		# through all the relations forward
		forward_rels.each do |rel_|

			if rel_.instance_of? Array then
				rel = ForwardRel.new( rel_[0], rel_[1] )
			elsif rel_.instance_of? ForwardRel
				rel = rel_
			else
				raise "invalid rel of class #{rel_.class}"
			end

			devolvio_todos = true
			#every relationship goes through their fields
			rel.fields.each do |field_origen, field_destino|

				devolvio_dato = false

				print field_origen,"\n"

				if devuelve
					dato = devuelve[field_origen] || devuelve[field_origen.to_sym] || devuelve[field_origen.to_s]

					if dato then
						# add a relationship to indicate the target circuit
						# the field to be filled with that value
						add_rel_circuit_data(  rel.circuito_destino, field_destino, dato )
						devolvio_dato = true
					end
				end

					#dato = args[field_origen] || args[field_origen.to_sym] || args[field_origen.to_s]
					#if dato then
					#	add_rel_circuit_data(  rel.circuito_destino, field_destino, args[field_origen]  )
					#	devolvio_dato = true
					#end

				unless devolvio_dato then
					devolvio_todos = false
					print "ERROR: no se puede obtener dato '#{field_origen}' de run #{id} para enviarlo a run #{rel.circuito_destino}:#{field_destino}\n"
					add_rel_error( rel.circuito_destino, "unable to read data '#{field_origen}' from run #{id}")
				end

			end

			if devolvio_todos then
				remove_rel_error( rel.circuito_destino)
			end
		end
	end

	def process_error(id, forward_rels, error )
		forward_rels.each do |rel_|

			if rel_.instance_of? Array then
				rel = ForwardRel.new( rel_[0], rel_[1] )
			elsif rel_.instance_of? ForwardRel
				rel = rel_
			else
				raise "invalid rel of class #{rel_.class}"
			end

			add_rel_error( rel.circuito_destino, error)
		end
	end

	def get_relations_args( id )

		args = Hash.new

		if @rel_run_data[ id ] then
			if @rel_run_data[id].error then
				raise "ocurrio un error al relacionar los datos de id=#{id}: #{@rel_run_data[id].error}\n"
			end

			@rel_run_data[ id ].fields.each do |field,value|
				args[field] = value
			end
		end

		return args
	end

	def run(args_, id, forward_rels )

		args = args_.dup
		# read all data stored for this circuit
		get_relations_args(id).each do |key,value|
			args[key] = value
		end
		 # TODO: validate that the above (from the data)
		 # error did not

		devuelve = yield(args)

		process_return_values(id, forward_rels, args, devuelve)
		return devuelve
	end

private
	def add_rel_error( circuito_destino, error )
		@rel_run_data[circuito_destino] = RelRunData.new unless @rel_run_data[circuito_destino]
		@rel_run_data[circuito_destino].error = error
	end
	def remove_rel_error( circuito_destino)
		@rel_run_data[circuito_destino] = RelRunData.new unless @rel_run_data[circuito_destino]
		@rel_run_data[circuito_destino].error = nil
	end
	def add_rel_circuit_data( circuito_destino, field, value )
			print "add relation to id=#{circuito_destino} #{field} => #{value}\n"

		@rel_run_data[circuito_destino] = RelRunData.new unless @rel_run_data[circuito_destino]
		@rel_run_data[circuito_destino].fields[ field ] = value

	end
end