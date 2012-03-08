class Manager < ActiveRecord::Base

  def self.connect( ip )
    require 'socket' 
    begin     
      manager = TCPSocket.new( ip, MANNAGER_PORT )
    rescue Exception => error 
      text_error = "Error when trying to connect to manager (ip: #{ip}, port: #{MANNAGER_PORT}): #{error}"
      manager = nil
      Notifier.deliver_notifier_error(text_error)
    end
    manager
  end

  def self.refresh(ip)
    manager = Manager.conect(ip)
    manager.print "refresh"
    manager.close
  end
end
