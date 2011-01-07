module SeleniumGrid
  module AWS
  
    class Cloud
      FILE = "cloud.yml"
      attr_accessor :hub, :farms
            
      def self.load
        begin
          YAML.load(File.read(FILE))
        rescue Errno::ENOENT
          new
        end
      end

      def self.update
        cloud = self.load
        yield cloud
      ensure
        cloud.write unless cloud.nil?
      end
      
      def write 
        File.open(FILE, "w") {|file| file.write(self.to_yaml)}
      end
      
      def farms
        @farms ||= []
      end
            
    end

  end
end

