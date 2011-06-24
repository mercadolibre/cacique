ADMIN_EMAIL="admin@myCaciqueAdmin.com"
#Datos para enviar mail desde Cacique
EMAIL =  "my_mail_user@my_server.com"
EMAIL_SERVER = "surgemail.cacique.com"
EMAIL_USER_NAME='cacique'
EMAIL_PASS='my_secure_mail'
EMAIL_AUTH = :login
EMAIL_PORT = 25
EMAIL_DOMAIN = "my_domain.com"
LOGGING_MAIL="cacique@my_domain.com"

#Primer usuario Generico de la herramienta
FIRST_USER_NAME="cacique"
FIRST_USER_PASS="admin"

#Default language
CACIQUE_LANG="en_US"

#Version
CACIQUE_VERSION = "0.1.12"

#funcion que calcula el ip del servidor
require 'socket'

def local_ip
  begin
  orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

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
LOCAL_IP=local_ip
IP_SERVER=local_ip

#Workers machines localip, es para mi maquina de desarrollo
WORKERS_ADDR=[LOCAL_IP]
WORKER_CACHE_KEY= "worker_#{LOCAL_IP}_#{$$}"

#Puerto del hub
HUB_PORT = 4444
#URL del hub
HUB_URL = "http://#{IP_SERVER}:#{HUB_PORT}/"

IP_QUEUE=IP_SERVER
PORT_QUEUE="22122"

module CaciqueConf
  SEND_MAIL = true
  DEBUG_MODE = false
  REMOTE_CONTROL_ADDR = "127.0.0.1"
  REMOTE_CONTROL_PORT = "4444"
  REMOTE_CONTROL_MODE = "hub"
end


VERSION_MAX_ENTRIES_FACTOR_CIRCUIT = 5
CIRCUIT_MIN_VERSION_ENTRIES = 5
VERSION_MAX_FOR_CIRCUIT = 5

VERSION_MAX_ENTRIES_FACTOR_FUNCTION = 5
FUNCTION_MIN_VERSION_ENTRIES = 5
VERSION_MAX_FOR_FUNCTION = 5

#this parameter is the amount of executions that scheduler will create before send an alert to confirm 

MAX_SUITE_PROGRAM = 300

#Constantes de tiempos de cacheo en seg.
CACHE_EXPIRE_EXEC = 7200 
CACHE_EXPIRE_SUITE_EXEC = 7200
CACHE_FUNCTIONS = 7200
CACHE_EXPIRE_PROYECT_SUITES = 7200
CACHE_EXPIRE_SUITES = 7200

