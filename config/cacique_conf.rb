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

config_file = File.read(RAILS_ROOT + "/config/cacique.yml")
CONFIG = YAML.load(config_file)

ADMIN_EMAIL="cacique@mercadolibre.com"
#Datos para enviar mail desde Cacique
EMAIL =  "cacique@mercadolibre.com"
EMAIL_SERVER = "surgemail.mercadolibre.com"
EMAIL_USER_NAME='cacique'
EMAIL_PASS='Cq123456'
EMAIL_AUTH = :login
EMAIL_PORT = 25
EMAIL_DOMAIN = "mercadolibre.com"
LOGGING_MAIL="robot@mercadolibre.com"

#Cacique First user 
FIRST_USER_NAME="cacique"
FIRST_USER_PASS="schumann"

#Default language
CACIQUE_LANG="en_US"

#Version
CACIQUE_VERSION = "0.1.14"


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

#URL del hub
HUB_URL = "http://"+CONFIG[:hub][:ip]+":"+CONFIG[:hub][:port].to_s+CONFIG[:hub][:rest]

#Queue observer
IP_QUEUE=CONFIG[:queue][:ip]
PORT_QUEUE=CONFIG[:queue][:port]

#Directory for file sharing
SHARED_DIRECTORY = "<file sharing route>"

#Circuits versions
VERSION_MAX_ENTRIES_FACTOR_CIRCUIT = 5
CIRCUIT_MIN_VERSION_ENTRIES = 5
VERSION_MAX_FOR_CIRCUIT = 5

#Functions versions
VERSION_MAX_ENTRIES_FACTOR_FUNCTION = 5
FUNCTION_MIN_VERSION_ENTRIES = 5
VERSION_MAX_FOR_FUNCTION = 5

#Amount of executions that scheduler will create before send an alert to confirm 
MAX_SUITE_PROGRAM = 300

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





