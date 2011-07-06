#!/usr/bin/env ruby

require "rubygems" 
require "socket"  
require 'memcache'

SERVER_IP="127.0.0.1"
 
cache = MemCache.new "#{SERVER_IP}:11211"

class WorkerMannager

  def initialize
    @cache = MemCache.new "#{SERVER_IP}:11211"
    puts @ip
    begin
      @cn=TCPServer.open(33133)
    rescue  Exception => e
       puts "Can't open host due: #{e.message}"
       exit(1)
    end

    @ip=self.get_ip 
    Signal.trap("TERM") {finalize}
    Signal.trap("SIGUSR1") {register_worker}
  end

  def finalize
    self.unregister_worker
    exit 0
  end

  def get_ip
  begin
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily
    UDPSocket.open do |s|
      s.connect '1.1.1.1', 1
      s.addr.last
    end
  rescue Exception => e
    puts "No hay conexion:" + e.message  
    return "127.0.0.1"
    end
  ensure 
    Socket.do_not_reverse_lookup = orig
  end

  #tell to the cacique server about himself
  def register_worker
    pids=`ps aux | grep 'workling' | grep -v grep | awk '{print $2}'`.gsub("\n",",").split(",")
    workers_hash=@cache.get("registred_workers")
    workers_hash={} if workers_hash==nil
    workers_hash[@ip] = pids
    @cache.set("registred_workers", workers_hash) 
    puts "worker registration was succefully for: #{@ip}"
  end
  
  def unregister_worker
    pids=`ps aux | grep 'workling' | grep -v grep | awk '{print $2}'`.gsub("\n",",").split(",")
    if pids.size == 0
       values=@cache.get("registred_workers")
       values.delete(@ip)
       puts "Deleting worker machine from server: #{@ip}"
       @cache.set("registred_workers", values)
    else
       register_worker 
    end
  end 
  
  #this methods handles request
  def listen
    require "socket"
    loop do
      Thread.start(@cn.accept) do |s|
        request=s.recv(1000)
        request=request.split(";")
         case request.first
         when "refresh"
           register_worker
         when "stop"
           stop(request[1],request[2])
           register_worker
         when "C"
           puts 'You need help!!!'
         else
           s.write("Ops, that is not an available command")
           s.close
          end
       end
    end
  end
  
  def stop(pid,exe)
     puts "Stopping execution #{exe} with pid #{pid}"
     Process.kill("SIGUSR2", pid.to_i)
  end


  def stop_execution
  puts "llego la señal"
  end

end

a=WorkerMannager.new
a.register_worker()
a.listen
