# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
require 'gettext/tools'
require 'gettext/utils'
#require 'gettext_rails/tools'


 require 'rubygems'

 # desc "Create mo files"
 # task :makemo do
 #   require 'gettext_rails/tools'
 #   GetText.create_mofiles
 # end

  #task :updatepo do
  #  require 'gettext_rails/tools'
    # Need to access DB to find Model table/column names.
    # Use config/database.yml which is the same style with rails.
  #  GetText.update_pofiles("cacique", Dir.glob("{app,lib,app}/**/*.{rb,rhtml,haml}"), "myapp 1.0.0")
  #end
