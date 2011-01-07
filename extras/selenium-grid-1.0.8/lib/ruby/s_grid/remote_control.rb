module SGrid

  class RemoteControl
    
    def initialize(options={})
      @host = options[:host] || "localhost"
      @port = (options[:port] || "4444").to_i
      @hub_url = options[:hub_url] || "http://localhost:4444"
      @shutdown_command = options[:shutdown_command] || "shutDownSeleniumServer"
    end

    def start(options={})
        # Selenium Server must be first in classpath
        root = File.expand_path(File.dirname(__FILE__) + "/../../..")
        classpath = Java::Classpath.new(root)
        classpath = classpath << "." << "vendor/selenium-server-*.jar" 
        classpath = classpath << "lib/selenium-grid-remote-control-standalone-*.jar"
        Java::VM.new.run "com.thoughtworks.selenium.grid.remotecontrol.SelfRegisteringRemoteControlLauncher",
                         options.merge(:classpath => classpath.definition, 
                                       :args => rc_args(options))
    end

    def shutdown
      http = Net::HTTP.new(@host, @port)
      http.post('/selenium-server/driver/', "cmd=#{@shutdown_command}")
    end

    def rc_args(options)
      args = []
      args << "-host" << @host
      args << "-port" << @port
      args << "-hubUrl" << @hub_url
      args << %Q{-env "#{options[:environment] || ENV['ENVIRONMENT'] || '*firefox'}"} 
      args << (options[:selenium_args] || ENV['SELENIUM_ARGS'] || "")
      args
    end

  end

end