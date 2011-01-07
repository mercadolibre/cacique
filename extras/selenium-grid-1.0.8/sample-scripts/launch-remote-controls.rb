#!/usr/bin/env ruby
#
# Launch a collection of remote controls
#

def launch_on_unix(title, command)
  terminal = ENV['TERM'] || "xterm"
    system "#{terminal} -t '#{title}' -e '#{command}'"
end

def launch_in_terminal(title, command)
  launch_on_unix(title, command)
end

first_port = ARGV[0] || 5555
last_port = ARGV[1] || 5555
base_directory = File.expand_path(File.dirname(__FILE__))
(first_port..last_port).each do |port|
  launch_in_terminal "Remote Control #{port}", "ant -Dport=#{port} launch-remote-control"
end
