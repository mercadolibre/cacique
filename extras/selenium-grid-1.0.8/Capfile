# Capistrano recipes for Managing the Selenium Grid
#
# Check out http://www.capify.org/ if you are not familiar with Capistrano
#
# Typical sequence:
#
# cap -f selenium_grid_deploy.rb grid restart_all
#
# Or if you want to control all the steps:
#
# cap -f selenium_grid_deploy.rb grid start_x11
# cap -f selenium_grid_deploy.rb grid launch_hub
# cap -f selenium_grid_deploy.rb grid launch_rcs
# ...

set :repository, "http://subversion.local/repository/my-project/trunk/"
set :user, "philippe"
set :password, "verysecure"

########### Environments ##########################

task :grid do
  role :hub, "192.168.0.24"
  role :rc, "192.168.0.24"
  set :grid_dir, "/home/philippe/selenium-grid-0.9.1"
end

########### Tasks ##################################

desc("Stop everything")
task :stop_all, :roles => [:rc, :hub ]do
  stop_rcs rescue nil
  stop_hub rescue nil
  stop_x11 rescue nil
end

desc("Start everything")
task :start_all, :roles => [:rc, :hub ]do
  start_x11
  launch_hub
  sleep 10
  launch_rcs
end

desc("Restart everything")
task :restart_all, :roles => [:rc, :hub ] do
  stop_all
  start_all
end

desc("Stop dedicated X server")
task :stop_x11, :roles => :rc do
  run "killall /usr/X11R6/bin/Xvnc"
end

desc("Start dedicated X server. Needed for remote controls.")
task :start_x11, :roles => :rc do
  run "nohup rake --rakefile selenium-grid-0.9.1/Rakefile xvnc:start",
      :env => { "PATH" => "/usr/X11R6/bin:/usr/local/bin:/usr/bin:/bin" }
end

desc("Display Selenium Hub Console in Firefox")
task :console, :roles => :hub do
  system "firefox http://192.168.0.24:4444/console"
end

desc("Launch Selenium Hub")
task :launch_hub, :roles => :hub do
  run "nohup rake --rakefile selenium-grid-0.9.1/Rakefile hub:start BACKGROUND=true",
      :env => { "PATH" => "/home/philippe/Applications/jdk-6.0/bin:/home/philippe/Applications/ant-1.7.0/bin:/usr/local/bin:/usr/bin:/bin" }
end

desc("Stop Selenium Hub")
task :stop_hub, :roles => :hub do
  run 'kill `lsof -t -i :4444`'
end

desc("Launch all remote controls")
task :launch_rcs, :roles => :rc do
  ports = ENV['ports'] || "6000-6020"
  port_range = Range.new(*ports.split("-"))
  port_range.each do |port|
    run remote_control_launch_command(port),
        :env => {
          "DISPLAY" => ":1",
          "PATH" => "/home/philippe/Applications/jdk-6.0/bin:/home/philippe/Applications/ant-1.7.0/bin:/usr/lib/firefox:/usr/local/bin:/usr/bin:/bin" }
  end
end

desc("Stop all remote controls")
task :stop_rcs, :roles => :rc do
  ports = ENV['ports'] || "6000-6020"
  run "kill `lsof -i :#{ports}`"
end

desc("View running browsers through VNC")
task :view_browsers_on_grid, :roles => :rc do
  if File.exists?('/Applications/Chicken of the VNC.app/Contents/MacOS/Chicken of the VNC')
    system "'/Applications/Chicken of the VNC.app/Contents/MacOS/Chicken of the VNC' --Display 1 192.168.0.24"
  else
    system 'vncviewer 192.168.0.24:1'
  end
end

def remote_control_launch_command(port)
 "nohup rake --rakefile #{grid_dir}/Rakefile rc:start  --trace PORT=#{port} BACKGROUND=true"
end