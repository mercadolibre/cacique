module SeleniumGrid
  module AWS
  
    class Hub < Server
      
      def url
        "http://#{public_dns}:4444"
      end

      def private_url
        "http://#{private_dns}:4444"
      end

      def console_url
        "#{url}/console"
      end
      
    end
    
  end
end

