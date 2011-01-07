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
require "#{RAILS_ROOT}/app/models/suite_cases_relation"

class SuiteRelation
  
  attr_accessor :data
  attr_accessor :executions_error
  
  def initialize( suite_cases_runner, suite_id )
	 @suite_cases_runner = suite_cases_runner
     @data = Hash.new
     @executions_error = Array.new
     @suite_id = suite_id
  end
  
  def find_relation(case_template_id, suite_id, suite_execution_id, use_db = false)
    
    @suite_case_relation = SuiteCasesRelation.new

    #Table Seting to CaseData
    @case_template = CaseTemplate.find(:first, :conditions => ["id = ?", case_template_id], :include => {:circuit => :category})
     
    #Add arguments for case_template into hash returned by suite_cases_runner
    @data = CaseTemplate.find(case_template_id).get_case_data
    
    unless @data
	raise "ERROR: no se puede encontrar case_template_id: #{case_template_id}\n"
    end
 
      #Verify if all case_template was Success
      father = SuiteCasesRelation.find(:all, :conditions  => [ "case_destination = ? and suite_id = ?", case_template_id, suite_id ], :select => "case_origin") 

      father.each do |f|
        raise FatherRelationError.new(f.case_origin) if @executions_error.include?(f.case_origin)
	    print "obteniendo datos relacionados de #{f.case_origin}\n"
      end

      if !father.empty?
        data_aux = Hash.new
	
	# can be SuiteCasesRunner (suite_cases_runner.rb)
	# or SuiteCasesRunnerDb (suite_cases_runner_db.rb)
	
        data_aux = @suite_cases_runner.get_relations_args(case_template_id)
    
        data_aux.each do |key,value|
		  print "dato relacionado: #{key} = #{value.inspect}\n"
          @data[key] = value
        end
      end
  end
  
  def process_return_values( case_template_id, args, devuelve) 
	  forward_rels = get_forward_rels(case_template_id)
	  @suite_cases_runner.process_return_values(  case_template_id, forward_rels, args, devuelve )
  end
  
  def get_forward_rels(case_template_id)
	  forward_rels = Array.new
	   
	 @case_template = CaseTemplate.find case_template_id
    
	  # find rels
	  rels = SuiteCasesRelation.find (:all, :conditions  => [ "case_origin = ? and suite_id = ?", case_template_id, @suite_id ] )
	  
	  rels.each do |rel|
		  case_destino = CaseTemplate.find rel.case_destination
		
		  fields_rels = SuiteFieldsRelation.find ( :all, :conditions => [ "circuit_origin_id = ? AND circuit_destination_id = ? AND suite_id = ?",  @case_template.circuit_id, case_destino.circuit_id, rel.suite_id ] )
			
		  fields = Hash.new
		  fields_rels.each do |frel|
			 fields[ frel.field_origin.to_sym ] = frel.field_destination.to_sym
		  end
		
		  #forward_rels << ::SuiteCasesRunner::ForwardRel.new( rel.case_destination, fields )
		  forward_rels << [ rel.case_destination, fields ]
		
	end
	
	return forward_rels
  end
  
  #Metod to manage Scripts Puts 
  def print(*x)
		self.output << x.join
		super(*x)
  end
  def p(*args)
		args.each do |x|
			self.print x.inspect,"\n"
		end
		nil
  end
  def puts(*args)
		args.each do |x|
			self.print x,"\n"
		end	
		nil
  end
  def output
		unless @output
			@output = String.new
		end	
		@output
  end
  def reset_output
		@output = String.new
  end
  
##############################################################
    class FatherRelationError < Exception
      def initialize(father)
        @father = father
      end
    
      def to_s
        "El caso Padre #{@father} dio error y por eso no se ejecuta."
      end
    end
##############################################################
#
end


