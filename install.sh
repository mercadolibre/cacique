#!/bin/bash
echo -e '\E[34m
         .::;:,.                                  ;GA3.                                                
       iM@@@@@@@&:                                 hhG                                                 
     &@@@@3ssiH@@@@:                                                                                   
    X@@@r       3@@5   ,h@@@@@M;      s#@@@@@S    ;##B    ,A@@@@A:B@@r  r@@#.    M@@X    :&@@@@@&.     
   .@@@2              s@@@h:r@@@9   ,@@@@ii#@@@r  2@@@   ;@@@#i5@@@@@s  i@@@,    @@@H   9@@@s:r@@@s    
   .@@@;              ,,.    ,@@@.  @@@X    r9A5  s@@@   @@@2    s@@@;  ;@@@     #@@3  ;@@@     @@@.   
    @@@i               .rh@@@#@@@, ,@@@:          r@@@  .@@@.     @@@;  :@@@     A@@X  9@@@#@@@@@@@S   
    &@@@        ,Gs:  @@@#:. ;@@@.  @@@;          ;@@@   @@@:     @@@;  :@@@     B@@X  5@@@,.,,        
     @@@@r     i@@@M ;@@@.   2@@@   X@@#    G@@#  ;@@@   B@@#    2@@@;  ,@@@s   r@@@X   @@@.    ...    
      X@@@@@@@@@@@r   @@@@GH@hA@@#i  9@@@#B@@@@:  r@@@    @@@@MB@@#@@;   X@@@@@@MA@@A   ,@@@#h&@@@h    
        :2M@@@Ar       ;9#@A,  sH@A   .i#@@Mi.    ,X3X     ;H@@B: B@@;    ,2M@#;  2hs     ;3@@@Ar      
                                                                  @@@;                                 
                                                                 .@@@r                                 
                                                                  ;rr.                                 
\e[00m'
 echo -e '\E[33m
                             ===================================================
                                      CHECKING SISTEM. PLEASE WAIT ...              
                             ===================================================
 \e[00m'
SYS=`uname -m`

if [ "$SYS" == "x86_64" ]
then
 sudo dpkg -i ./extras/dialog_64.deb 2>>installer.log
else
 sudo dpkg -i ./extras/dialog_i386.deb 2>>installer.log  
fi

 sudo apt-get update 2>>installer.log
 sudo apt-get install build-essential -y 2>>installer.log

sleep 3

 dialog --backtitle "CACIQUE" --msgbox \
'
 ===================================================
                CACIQUE INSTALATION              
 ---------------------------------------------------

          This process may take some times,        
               so please be patient...             

 ===================================================
' 13 58
 echo " "
 echo " " 
 echo "======================================================================================================" >> installer.log
 date >> installer.log
 echo "======================================================================================================" >> installer.log
 echo " "
(
c=0
 echo $c; ((c+=10)); sleep 1
  sudo useradd cacique -M -p saswVy4vvLXGM 2>>installer.log
  sudo mkdir -p ~/cacique
 echo $c; ((c+=40)); sleep 1
  sudo cp -r * ~/cacique
  cd ~/cacique
 echo $c; ((c+=50)); sleep 1
 USRGRP=`groups $LOGNAME | awk '{ print $3}'`
 sudo chown -R $LOGNAME:$USRGRP ~/cacique
 echo $c; sleep 1
 exit 1
) |
dialog --backtitle "CACIQUE" --title "CACIQUE CONFIG" --gauge "  Creating Cacique User and Aplication Environment ..." 7 80 00


(
c=0
   sudo apt-get install ruby1.8 -y 2>>installer.log
 echo $c; ((c+=4)); sleep 1
   sudo apt-get install ruby1.8-dev -y 2>>installer.log
 echo $c; ((c+=5)); sleep 1
   sudo apt-get install rubygems -y 2>>installer.log
 echo $c; ((c+=3)); sleep 1
   sudo apt-get install g++ -y 2>>installer.log
 echo $c; ((c+=6)); sleep 1
   sudo apt-get install libxslt -dev -y 2>>installer.log
 echo $c; ((c+=2)); sleep 1
   sudo apt-get install libopenssl-ruby -y 2>>installer.log
 echo $c; ((c+=3)); sleep 1
   sudo apt-get install graphviz -y 2>>installer.log
 echo $c; ((c+=2)); sleep 1
   sudo apt-get install build-essential -y 2>>installer.log
 echo $c; ((c+=4)); sleep 1
   sudo apt-get install libmysql-ruby -y 2>>installer.log
 echo $c; ((c+=4)); sleep 1
   sudo apt-get install apache2 libcurl4-openssl-dev libssl-dev apache2-prefork-dev libapr1-dev libaprutil1-dev -y 2>>installer.log
 echo $c; ((c+=5)); sleep 1
   sudo apt-get install mysql-client mysql-common -y 2>>installer.log
 echo $c; ((c+=2)); sleep 1
   sudo mysqladmin -u cacique password cacique 2>>installer.log
 echo $c; ((c+=5)); sleep 1
   sudo apt-get install libc6-dev gcc libfcgi-dev ruby1.8-dev -y 2>>installer.log
 echo $c; ((c+=5)); sleep 1 #50
   sudo apt-get install libfcgi-ruby1.8 libfcgi-dev -y 2>>installer.log
 echo $c; ((c+=8)); sleep 1
   sudo apt-get install catdoc -y 2>>installer.log
 echo $c; ((c+=4)); sleep 1
   sudo apt-get install curl -y 2>>installer.log
 echo $c; ((c+=1)); sleep 1
   sudo apt-get install memcached -y 2>>installer.log
 echo $c; ((c+=7)); sleep 1
   sudo gem install starling -y 2>>installer.log
 echo $c; ((c+=7)); sleep 1
   sudo gem install rubygems-update -v 1.3.6 -y 2>>installer.log
 echo $c; ((c+=3)); sleep 1
   sudo gem install RbYAML -y 2>>installer.log
 echo $c; ((c+=7)); sleep 1
   sudo gem install bundler -y 2>>installer.log
 echo $c; ((c+=5)); sleep 1
  sudo gem install passenger -v 3.0.7 -y 2>>installer.log
 echo $c; ((c+=6)); sleep 1
  sudo apt-get install openjdk-6-jre -y 2>>installer.log
 echo $c; ((c+=1)); sleep 1
  sudo apt-get install openjdk-6-jdk -y  2>>installer.log
 echo $c; ((c+=1)); sleep 1
 echo $c; sleep 2
 exit 1
) |
dialog --backtitle "CACIQUE" --title "CACIQUE CONFIG" --gauge "  Gems Installation" 7 80 00


(
c=0
 echo $c; ((c+=15)); sleep 2
  /var/lib/gems/1.8/bin/./update_rubygems
 echo $c; ((c+=83)); sleep 2 
   sudo passenger-install-apache2-module -a 2>>installer.log
 echo $c; ((c+=2)); sleep 2 
   sudo /etc/init.d/apache2 restart
#
 echo $c; sleep 2
 exit 1
) |
dialog --backtitle "CACIQUE" --title "CACIQUE CONFIG" --gauge "  Installing PASSENGER" 7 80 00


(
c=0
 echo $c; ((c+=10)); sleep 2
 echo $c; ((c+=90)); sleep 2
 export DEBIAN_FRONTEND=noninteractive
  sudo apt-get -q -y install mysql-server 2>>installer.log
 #
 echo $c; sleep 2
 exit 1
) |
dialog --backtitle "CACIQUE" --title "CACIQUE CONFIG" --gauge "  Installing MySQL SERVER" 7 80 00


 
 dialog --backtitle "CACIQUE" --title "CACIQUE INSTALLATION" --infobox \
"

Give mysql server time to start. Please Wait .... 


" 7 80 ; sleep 10



(
c=0
 echo $c; ((c+=100)); sleep 2
mysql -uroot -e <<EOSQL "UPDATE mysql.user SET Password=PASSWORD('cacique') WHERE User='cacique'; FLUSH PRIVILEGES;"
EOSQL
 echo $c; sleep 2
 exit 1
) |
dialog --backtitle "CACIQUE" --title "CACIQUE CONFIG" --gauge "  Generating Data Base User" 7 80 00



(
c=0
 echo $c; ((c+=11)); sleep 2
   IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
 echo $c; ((c+=34)); sleep 2
   sudo sed -e s/acavalaip/$IP/g ./conf/apache2.conf > /etc/apache2/apache2.conf 2>>installer.log
 echo $c; ((c+=55)); sleep 2
   sudo /etc/init.d/apache2 restart
 #
 echo $c; sleep 2
 exit 1
) |
dialog --backtitle "CACIQUE" --title "CACIQUE CONFIG" --gauge "  Configuring APACHE" 7 80 00


(
c=0
 echo $c; ((c+=3)); sleep 2
 echo $c; ((c+=2)); sleep 2
   sudo bundle install --local 2>>installer.log
 echo $c; ((c+=95)); sleep 2
 #
 echo $c; sleep 2
 exit 1
) |
dialog --backtitle "CACIQUE" --title "CACIQUE CONFIG" --gauge "  Running Bundle Install" 7 80 00

######################################################################

LINEAS=`cat /etc/profile | grep gems | wc -l`
if [ $LINEAS = 0  ]
then
  var=`gem env gempath`
  sudo echo 'export PATH='${var//://bin:}'/bin:$PATH'  >> /etc/profile
  sudo source /etc/profile
fi

LINEAS=`grep '.gem/ruby/1.8/bin' $HOME/.bashrc | wc -l` 
if [ $LINEAS = 0 ]
then
  PATH='$PATH':$HOME/.gem/ruby/1.8/bin >> $HOME/.bashrc
  sudo echo PATH='$PATH':$HOME/.gem/ruby/1.8/bin >> $HOME/.bashrc
fi
sudo /bin/ln -s /usr/bin/ruby1.8 /usr/bin/ruby

#######################################################################

./setup.sh


 dialog --backtitle "CACIQUE" --msgbox \
'
 ===================================================
              INSTALLATION SUCCESS !!             
 ---------------------------------------------------

            PLEASE RUN  * startup.sh *       
                  FROM ~/CACIQUE             

 ---------------------------------------------------

 If you need more information, please contact us to 
 robot@mercadolibre.com

  Thank you for choose Cacique :) [ Cacique Team ]
 ===================================================
' 20 58
clear
