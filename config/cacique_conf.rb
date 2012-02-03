#  @Authors:    
#      Guerra Brenda                   brenda.guerra.7@gmail.com
#      Crosa Fernando                  fernandocrosa@hotmail.com
#      Branciforte Horacio             horaciob@gmail.com
#      Luna Juan                       juancluna@gmail.com
#      
#  @copyright (C) 2010 MercadoLibre S.R.L
#
#
#  @license        GNU/GPL, see license.txt
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see http://www.gnu.org/licenses/.
#

require "rubygems"
gem "RbYAML"
require "yaml"

config_file = File.read(RAILS_ROOT + "/config/cacique.yml")
CONFIG = YAML.load(config_file)

ADMIN_EMAIL="admin@mysourcemail.com"
#Datos para enviar mail desde Cacique
EMAIL =  "caciquemail@mysourcemail.com"
EMAIL_SERVER = "sourcemail.mymail.com"
EMAIL_USER_NAME='myusername'
EMAIL_PASS='mypass'
EMAIL_AUTH = :login
EMAIL_PORT = 25
EMAIL_DOMAIN = "mydomain.com"
LOGGING_MAIL="mysuser@mydomain.com"

#Cacique First user
FIRST_USER_NAME="cacique"
FIRST_USER_PASS="admin"

#Default language
CACIQUE_LANG="en_US"

#Version
CACIQUE_VERSION = "0.2.5.4"


#Function that calculates the server ip
#------------------------------------------------------------------------
def local_ip
  begin
  # turn off reverse DNS resolution temporarily
  orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  
  UDPSocket.open do |s|
    s.connect '1.1.1.1', 1
    s.addr.last
  end
  rescue => e
    puts "No hay conexion " + e
    return "127.0.0.1"
  end
ensure
  Socket.do_not_reverse_lookup = orig
end
#------------------------------------------------------------------------


#Ips config
SERVER_DOMAIN=CONFIG[:server][:domain]
LOCAL_IP=local_ip
IP_SERVER=CONFIG[:server][:ip]
IP_DB=CONFIG[:db][:ip]
MANNAGER_PORT=CONFIG[:mannager][:port]

#Workers machines localip
WORKERS_ADDR=[LOCAL_IP]
WORKER_CACHE_KEY= "worker_#{LOCAL_IP}_#{$$}"

#Puerto del hub
HUB_IP = CONFIG[:hub][:ip]
HUB_PORT = CONFIG[:hub][:port]
WEBDRIVER_HUB_IP=CONFIG[:webdriverdhub][:ip]
WEBDRIVER_HUB_PORT=CONFIG[:webdriverdhub][:port]

#URL del hub
HUB_URL = "http://"+CONFIG[:hub][:ip]+":"+CONFIG[:hub][:port].to_s+CONFIG[:hub][:end]

#Queue observer
IP_QUEUE=CONFIG[:starling][:ip]
PORT_QUEUE=CONFIG[:starling][:port]

#Directory for file sharing
SHARED_DIRECTORY = "<shared_directory>"

#Circuits versions
VERSION_MAX_ENTRIES_FACTOR_CIRCUIT = 5
CIRCUIT_MIN_VERSION_ENTRIES = 5
VERSION_MAX_FOR_CIRCUIT = 5

#Functions versions
VERSION_MAX_ENTRIES_FACTOR_FUNCTION = 5
FUNCTION_MIN_VERSION_ENTRIES = 5
VERSION_MAX_FOR_FUNCTION = 5

#Functions: creation default
FUNCTION_HIDE_DEFAULT     = false
FUNCTION_PRIVATED_DEFAULT = true

#Amount of executions that scheduler will create before send an alert to confirm 
MAX_SUITE_PROGRAM = 300

#Timeout that system is going to wait before stop an atomic execution
ATOMIC_TIMEOUT = 90

#Constants caching time (seconds)
CACHE_EXPIRE_EXEC = 7200 
CACHE_EXPIRE_SUITE_EXEC = 7200
CACHE_FUNCTIONS = 7200
CACHE_EXPIRE_PROYECT_SUITES = 7200
CACHE_EXPIRE_SUITES = 7200

#Default context configuration
module CaciqueConf
  SEND_MAIL = true
  DEBUG_MODE = false
  REMOTE_CONTROL_ADDR = "127.0.0.1"
  REMOTE_CONTROL_PORT = "4444"
  REMOTE_CONTROL_MODE = "hub"
end

