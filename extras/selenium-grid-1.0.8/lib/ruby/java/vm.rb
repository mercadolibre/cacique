module Java

  class VM

    def run(classname, options)
      command = [ "java" ]
      command << "-cp \"#{options[:classpath]}\""
      command << classname
      command << jvm_properties(options[:properties])
      command << options[:args].join(' ') if options[:args]
      command << ">\"#{options[:log_file]}\" 2>&1" if options[:log_file]

      if options[:background]
        if PLATFORM['win32']
          command.unshift("start")
        else
          command << "&"
          command << " echo $! > #{options[:pid_file]}" if options[:pid_file]
        end
      else
        command << "; echo $! > #{options[:pid_file]}" if options[:pid_file]
      end

      sh command.join(' ')
    end

    def jvm_properties(property_hash)
      return "" unless property_hash
      property_hash.inject([]) {|memo, (name, value)| memo << "-D#{name}=#{value}" }.join(' ')
    end

  end

end
