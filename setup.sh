#!/bin/bash

IP=`ifconfig  | grep -E 'inet addr:|Direc. inet:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
RUTA=`pwd`

dialog --backtitle "CACIQUE" --title "CACIQUE CONFIGURATION"\
  --radiolist "Select Configuration type:" 10 40 2 \
        1 MANUAL off \
        2 AUTOMATIC on 2>tempfile

retval=$?
choice=`cat tempfile`
case $choice in
  1)
dialog 	  --backtitle "CACIQUE" \
	  --title "CACIQUE CONFIG" \
	  --form "Server Config
 * Use [up] [down] to select input field 
" \
8 50 0 \
	"Server IP:"      1 2 "$SERVIP"      1 16 15 0 \
        "Server DOMAIN:"  2 2 "cacique.ml.com"     2 16 28 0 2>dialog.ans

    cat /dev/null > ./config/cacique.yml
    SERVIP=`awk 'NR==1' dialog.ans`
    SERVDOM=`awk 'NR==2' dialog.ans`
    echo ":server:" >> ./config/cacique.yml
    echo "  :ip: $SERVIP" >> ./config/cacique.yml
    echo "  :domain: '$SERVDOM'" >> ./config/cacique.yml
    echo "    " >> ./config/cacique.yml


dialog 	  --backtitle "CACIQUE" \
	  --title "CACIQUE CONFIG" \
	  --form "Config Data Base
 * Use [up] [down] to select input field 
" \
13 50 0 \
	"DB Name:"  1 2	"$DBNAME" 	1 13 20 0 \
	"User:"     2 2	"$DBUSER"  	2 13 20 0 \
	"Password:" 3 2	"$DBPASS"  	3 13 20 0 \
	"Host:"     4 2	"$DBHOST" 	4 13 15 0 \
	"Port:"	    5 2 "3306"       5 13  5 0 2>dialog.ans

    DBNAME=`awk 'NR==1' dialog.ans`
    DBUSER=`awk 'NR==2' dialog.ans`
    DBPASS=`awk 'NR==3' dialog.ans`
    DBHOST=`awk 'NR==4' dialog.ans`
    DBPORT=`awk 'NR==5' dialog.ans`

    echo ":db:" >> ./config/cacique.yml
    echo "  :production:" >> ./config/cacique.yml
    echo "    :adapter: mysql" >> ./config/cacique.yml
    echo "    :encoding: utf8" >> ./config/cacique.yml
    echo "    :name: $DBNAME" >> ./config/cacique.yml
    echo "    :pool: 5" >> ./config/cacique.yml
    echo "    :username: $DBUSER" >> ./config/cacique.yml
    echo "    :password: $DBPASS" >> ./config/cacique.yml  
    echo "    :host: $DBHOST" >> ./config/cacique.yml
    echo "    :port: $DBPORT" >> ./config/cacique.yml
    echo "  :development:" >> ./config/cacique.yml
    echo "    :adapter: mysql" >> ./config/cacique.yml
    echo "    :encoding: utf8" >> ./config/cacique.yml
    echo "    :name: cacique_dev" >> ./config/cacique.yml
    echo "    :pool: 5" >> ./config/cacique.yml
    echo "    :username: cacique" >> ./config/cacique.yml
    echo "    :password: cacique" >> ./config/cacique.yml  
    echo "    :host: localhost" >> ./config/cacique.yml
    echo "    :port: 3306" >> ./config/cacique.yml
    echo "  :test:" >> ./config/cacique.yml
    echo "    :adapter: mysql" >> ./config/cacique.yml
    echo "    :encoding: utf8" >> ./config/cacique.yml
    echo "    :name: cacique_test" >> ./config/cacique.yml
    echo "    :pool: 5" >> ./config/cacique.yml
    echo "    :username: cacique" >> ./config/cacique.yml
    echo "    :password: cacique" >> ./config/cacique.yml  
    echo "    :host: localhost" >> ./config/cacique.yml
    echo "    :port: 3306" >> ./config/cacique.yml
    echo "    " >> ./config/cacique.yml

dialog 	  --backtitle "CACIQUE" \
	  --title "CACIQUE CONFIG" \
	  --form "Config Services
 * Use [up] [down] to select input field 
" \
13 50 0 \
	"Memcahed IP:"   1 2 "$MEMIP" 	1 16 15 0 \
	"Mannager IP:"   2 2 "$TMIP"  	2 16 15 0 \
	"Mannager PORT:" 3 2 "33133"    3 16  6 0 \
	"Starling IP:"   4 2 "$STIP"  	4 16 15 0 \
	"Starling PORT:" 5 2 "22122"    5 16  6 0 2>dialog.ans

    MEMIP=`awk 'NR==1' dialog.ans`
    TMIP=`awk 'NR==2' dialog.ans`
    TMPORT=`awk 'NR==3' dialog.ans`
    STIP=`awk 'NR==4' dialog.ans`
    STPORT=`awk 'NR==5' dialog.ans`

    echo ":memcached:" >> ./config/cacique.yml
    echo "  :ip: $MEMIP" >> ./config/cacique.yml
    echo "    " >> ./config/cacique.yml
    echo ":starling:" >> ./config/cacique.yml
    echo "  :ip: $STIP" >> ./config/cacique.yml
    echo "  :port: $STPORT" >> ./config/cacique.yml
    echo "    " >> ./config/cacique.yml
    echo ":mannager:" >> ./config/cacique.yml
    echo "  :ip: $TMIP" >> ./config/cacique.yml
    echo "  :port: $TMPORT" >> ./config/cacique.yml    
    echo "    " >> ./config/cacique.yml


dialog 	  --backtitle "CACIQUE" \
	  --title "CACIQUE CONFIG" \
	  --form "Config Selenium HUB
 * Use [up] [down] to select input field 

- For URL END use:
                  '/' for Selenium1
                  '/wd/hub' for WEBDRIVER
" \
13 50 0 \
	"HUB IP:"      1 2   "$HUBIP" 	1 15 15 0 \
	"HUB PORT:"    2 2   "4444" 2 15  5 0 \
	"HUB URL END:" 3 2   "/"  3 15 15 0 2>dialog.ans

    HUBIP=`awk 'NR==1' dialog.ans`
    HUBPORT=`awk 'NR==2' dialog.ans`
    HUBEND=`awk 'NR==3' dialog.ans`

    echo ":hub:" >> ./config/cacique.yml
    echo "  :ip: $HUBIP" >> ./config/cacique.yml
    echo "  :port: $HUBPORT" >> ./config/cacique.yml
    echo "  :end: '$HUBEND'" >> ./config/cacique.yml
    echo "    " >> ./config/cacique.yml
    echo ":webdriverdhub:" >> ./config/cacique.yml
    echo "  :ip: $HUBIP" >> ./config/cacique.yml
    echo "  :port: $HUBPORT" >> ./config/cacique.yml
    echo "    " >> ./config/cacique.yml

    rm dialog.ans
    rm tempfile

    ruby config.rb
mysql -uroot -e <<EOSQL "UPDATE mysql.user SET Password=PASSWORD('$PASSDB') WHERE User='$USRDB'; FLUSH PRIVILEGES;"
EOSQL
    sudo sed -i s/acavalaruta/$RUTA/g /etc/apache2/apache2.conf 2>>installer.log
    sudo /etc/init.d/apache2 restart
    ;;
  2)
   IP=`ifconfig  | grep -E 'inet addr:|Direc. inet:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
   echo $IP
   sed "s/LOCALIP/$IP/g" ./config/default.cfg > ./config/cacique.yml
   dialog --backtitle "CACIQUE" --title "CACIQUE INSTALLATION" --infobox \
"
Configuring CACIQUE. Please Wait .... 

" 5 80;sleep 3
    rm tempfile
    ruby config.rb
mysql -uroot -e <<EOSQL "UPDATE mysql.user SET Password=PASSWORD('cacique') WHERE User='cacique'; FLUSH PRIVILEGES;"
EOSQL
    sudo sed -i s/acavalaruta/$RUTA/g /etc/apache2/apache2.conf 2>>installer.log
    sudo /etc/init.d/apache2 restart
    ;;
  255)
    echo "ESC pressed.";;
esac

dialog 	  --backtitle "CACIQUE" \
	  --title "CACIQUE CONFIG" \
          --textbox ./config/cacique.yml 27 40
clear
