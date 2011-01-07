#Datos para enviar mail desde Cacique
EMAIL =  "mail@mercadolibre.com"
EMAIL_SERVER = "server"
EMAIL_USER_NAME='user'
EMAIL_PASS='password'
EMAIL_AUTH = :login
EMAIL_PORT = 25
EMAIL_DOMAIN = "dominio"
LOGGING_MAIL="cambiar_mail@delogueo.com"

#history date
HISTORY_INIT_DATE="1.1.2010 00:00"


#Primer usuario Generico de la herramienta
FIRST_USER_NAME="cacique"
FIRST_USER_PASS="admin"

#Default language
CACIQUE_LANG="en_US"

#Version
CACIQUE_VERSION = "0.1.0 beta"

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
IP_SERVER="localhost"

#Puerto del hub
HUB_PORT = 4444
#URL del hub
HUB_URL = "http://#{LOCAL_IP}:#{HUB_PORT}/"

IP_QUEUE=IP_SERVER
PORT_QUEUE="22122"

module CaciqueConf
  SEND_MAIL = true
  DEBUG_MODE = false
  REMOTE_CONTROL_ADDR = "127.0.0.1"
  REMOTE_CONTROL_PORT = "4444"
  REMOTE_CONTROL_MODE = "hub"
end


VERSION_MAX_ENTRIES_FACTOR = 5
CIRCUIT_MIN_VERSION_ENTRIES = 5
VERSION_MAX_FOR_CIRCUIT = 5

#Constantes de tiempos de cacheo en seg.
CACHE_EXPIRE_EXEC = 7200 
CACHE_EXPIRE_SUITE_EXEC = 7200
CACHE_FUNCTIONS = 7200
CACHE_EXPIRE_PROYECT_SUITES = 7200
CACHE_EXPIRE_SUITES = 7200

