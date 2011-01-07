require File.expand_path(File.dirname(__FILE__) + '/array_extension')
Array.send :include, ArrayExtension

class MultiProcessSpecRunner

  def initialize(max_concurrent_processes = 10)
    @max_concurrent_processes = max_concurrent_processes
  end
  
  def run(spec_files)
    concurrent_processes = [ @max_concurrent_processes, spec_files.size ].min
    spec_files_by_process = spec_files / concurrent_processes
    concurrent_processes.times do |i|
      cmd  = "spec #{spec_files_by_process[i].join(' ')}"
      puts "Launching #{cmd}"
      exec(cmd) if fork == nil
    end
    success = true
    concurrent_processes.times do |i|
      pid, status = Process.wait2
      puts "Test process ##{i} with pid #{pid} completed with #{status}"
      success &&= status.exitstatus.zero?
    end
    
    raise "Build failed" unless success
  end

end
