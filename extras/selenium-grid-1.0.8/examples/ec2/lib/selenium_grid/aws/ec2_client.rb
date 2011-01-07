module SeleniumGrid
  module AWS
    module Ec2Client
      
      def describe(instance_id)
        output = ec2_shell "ec2-describe-instances #{instance_id}"
        output =~ /INSTANCE\s+(i-.*)$/
        fields = $1.split(/\s+/)
        if output =~ /running/
          {:instance_id => fields[0],
           :ami => fields[1],
           :public_dns => fields[2],
           :private_dns => fields[3],
           :status => fields[4] }
        else 
          {:instance_id => fields[0],
           :ami => fields[1],
           :status => fields[2] }
        end
      end
            
      def launch(ami, options ={})
        output = ec2_shell "ec2-run-instances #{ami} -k #{options[:keypair]}"
        output =~ /INSTANCE\s+(i-\S+)\s+ami-/
        if $1 != nil
          $1
        else
          raise InstanceLaunchError, output
        end
      end

      def shutdown(instance_id)
        ec2_shell "ec2-terminate-instances #{instance_id}"
      end

      def version
        ec2_shell "ec2-version"
      end
            
      def authorize_port(port)
        puts "Opening port #{port}..."        
        ec2_shell "ec2-authorize default -p #{port}"
      end
            
      def ec2_shell(command)
        puts "[EC2] '#{command}'" if tracing?
        output = `${EC2_HOME}/bin/#{command}`
        puts "[EC2] #{output}" if tracing?
        output
      end

      def tracing?
        ENV['TRACE_EC2_COMMANDS']
      end
              
    end
  end
  
  class InstanceLaunchError < StandardError
  end
  
end
