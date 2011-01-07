module SGrid

  class Hub
    
    def initialize(options={})
      @host = options[:host] || "localhost"
      @port = (options[:port] || "4444").to_i
    end
    
    def start(options={})
      root = File.expand_path(File.dirname(__FILE__) + "/../../..")
      classpath = Java::Classpath.new(root)
      classpath = classpath << "." << "lib/selenium-grid-hub-standalone-*.jar"
      Java::VM.new.run "com.thoughtworks.selenium.grid.hub.HubServer",
                        options.merge(:classpath => classpath.definition)
    end

    def wait_until_up_and_running
      TCPSocket.wait_for_service :host => @host, :port => @port
    end

    def shutdown
      http = Net::HTTP.new(@host, @port)
      http.post('/lifecycle-manager', "action=shutdown")
    end
    
  end

end