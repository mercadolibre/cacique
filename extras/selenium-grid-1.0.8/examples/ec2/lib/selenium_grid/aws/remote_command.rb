module SeleniumGrid
  module AWS
    
    class RemoteCommand
      attr_accessor :options
      
      def initialize(command, options={})
        @command, @options = command, options
      end
      
      def execute
        puts full_command
        system full_command
        raise "Error with #{full_command}" if 0 != $?        
      end
      
      def full_command
        cmd = "#{ssh_command} " 
        cmd << "\"su -l #{options[:su]} -c " if options[:su]
        cmd << "'#{remote_command}'"
        cmd << '"' if options[:su]
        cmd
      end
      
      def ssh_command
        shell_command = [ "ssh" ]
        shell_command << "-i '#{options[:keypair]}'" if options[:keypair]
        shell_command << "root@#{options[:host]}"
        
        shell_command.join " "
      end

      def remote_command
        shell_command = []
        shell_command << "PATH=#{options[:path]}:${PATH}; export PATH;" if options[:path]
        shell_command << "DISPLAY=#{options[:display]}; export DISPLAY;" if options[:display]
        shell_command << "cd '#{options[:pwd]}';" if options[:pwd]
        shell_command << @command
        
        shell_command.join " "
      end
      
    end  

  end
end

