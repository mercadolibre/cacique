class FakeOracleLogger
	
	def initialize( real_oracle, output )
		@output = output
		@real_oracle = real_oracle
	end
	
	def method_missing(m, *args)
		@output.print "oracle.#{m.to_s}( #{args.map{|x| "\"#{x}\"" }.join(", ") } )\n"
		
		@output.print "{\n"
		
		aux = @real_oracle.send(m,*args) do |tempreg|
			@output.print " - #{tempreg.inspect}\n"
			yield(tempreg) if block_given?
		end
		@output.print "} => '#{aux}'\n"
		
		return aux
	end
end