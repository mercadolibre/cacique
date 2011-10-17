require "rubygems"
gem "RbYAML"
require "yaml"
config_file = File.read(Dir.pwd + "/config/cacique.yml")
CONFIG = YAML.load(config_file)
#puts Dir.pwd


def write(filename, hash)
  File.open(filename, "w") do |f|
    f.write(hash)
  end
end





#MEMCACHED CONFIG

memcached = '#!/bin/bash
case "$1" in
  start)
        /usr/bin/memcached -P /tmp/memcached.pid -u cacique  -d -l '+CONFIG[:memcached][:ip]+'
        sleep 1
  ;;
  stop)
        /bin/rm /tmp/memcached.pid
        kill `pgrep memcached`
  ;;
esac
'

#DB CONFIG

CONFIG[:db][:development][:adapter]

dbconf= '#   SQLite version 3.x
#   gem install sqlite3-ruby (not necessary on OS X Leopard)

development:
  adapter: '+CONFIG[:db][:development][:adapter]+'
  encoding: '+CONFIG[:db][:development][:encoding]+'
  database: '+CONFIG[:db][:development][:database]+'
  pool: '+(CONFIG[:db][:development][:pool]).to_s+'
  username: '+CONFIG[:db][:development][:username]+'
  password: '+CONFIG[:db][:development][:password]+'
  host: '+CONFIG[:db][:development][:host]+'

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  adapter: '+CONFIG[:db][:test][:adapter]+'
  encoding: '+CONFIG[:db][:test][:encoding]+'
  database: '+CONFIG[:db][:test][:database]+'
  pool: '+(CONFIG[:db][:test][:pool]).to_s+'
  username: '+CONFIG[:db][:test][:username]+'
  password: '+CONFIG[:db][:test][:password]+'
  host: '+CONFIG[:db][:test][:host]+'

production:
  adapter: '+CONFIG[:db][:production][:adapter]+'
  encoding: '+CONFIG[:db][:production][:encoding]+'
  database: '+CONFIG[:db][:production][:database]+'
  pool: '+(CONFIG[:db][:production][:pool]).to_s+'
  username: '+CONFIG[:db][:production][:username]+'
  password: '+CONFIG[:db][:production][:password]+'
  host: '+CONFIG[:db][:production][:host]+'
'



#WORKLING CONFIG


workling="# By default, NotRemoteRunner is used when RAILS_ENV == 'test'.
#
# You can pass options to memcached client by nesting the key value pairs
# under 'memcache_options'.
#
# You can also use a cluster of Starlings. Simply give a comma separated
# list of server:port, server:port, server:port values to listens_on. 
#
production:
  listens_on:  "+CONFIG[:workling][:production]+"

development:
  listens_on:  "+CONFIG[:workling][:development]+"

test:
  listens_on:  "+CONFIG[:workling][:test]+"
"


#ENVIRONMENT PRODUCTION CONF

env_prod = '# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Enable threaded mode
# config.threadsafe!

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Use a different cache store in production
 config.cache_store = :mem_cache_store,"'+CONFIG[:memcached][:ip]+'"

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
'



#STARLING CONF


starling = '#!/bin/bash
case "$1" in
  start)
     exec '+Dir.pwd+'/script/starling.rb -h '+CONFIG[:queue][:ip]+' >  /dev/null &
  ;;
  stop)
     exec /bin/kill `/bin/cat /var/run/starling.pid`
  ;;
esac
'

#MANNAGER CONF

mannager= '#!/bin/bash
case "$1" in
  start)
        cd '+Dir.pwd+'
        exec script/mannager.rb > /dev/null &
        pgrep -f mann > '+Dir.pwd+'/log/task_manager.pid
  ;;
  stop)
        rm '+Dir.pwd+'/log/task_manager.pid
        kill `pgrep -f mann`
  ;;
esac
'

#RAKE_JOBS

rake_jobs= '#!/bin/bash
case "$1" in
  start)
        cd '+Dir.pwd+'
        exec rake jobs:work RAILS_ENV=production > /dev/NULL &
        pgrep -f jobs:work > /tmp/rake_jobs.pid
  ;;
  stop)
        rm /tmp/rake_jobs.pid
        kill `pgrep -f jobs:work`
  ;;
esac
'


####





write(Dir.pwd + "/config/database.yml",dbconf)
write(Dir.pwd + "/config/workling.yml",workling)
write(Dir.pwd + "/config/environments/production.rb",env_prod)
write(Dir.pwd + "/script/memcached.sh",memcached)
write(Dir.pwd + "/script/starling",starling)
write(Dir.pwd + "/script/manager",mannager)
write(Dir.pwd + "/script/rake_jobs",rake_jobs)



