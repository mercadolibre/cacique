#!/bin/bash
 echo $USER
 echo "===============================================" >> installer.log
 date>> installer.log
 echo "-----------------------------------------------" >> installer.log
 sudo apt-get install ruby1.8 2>> installer.log
 sudo apt-get install ruby1.8-dev  2>> installer.log
 sudo apt-get install rubygems   2>> installer.log
 sudo apt-get install g++   2>> installer.log
 sudo apt-get install libxslt1-dev  2>> installer.log
 sudo apt-get install libopenssl-ruby  2>> installer.log
 sudo apt-get install graphviz   2>> installer.log
 sudo apt-get install build-essential  2>> installer.log
 sudo apt-get install libmysql-ruby   2>> installer.log
 sudo apt-get install apache2 libcurl4-openssl-dev libssl-dev apache2-prefork-dev libapr1-dev libaprutil1-dev  2>> installer.log
 sudo apt-get install mysql-server mysql-server  2>> installer.log
 sudo apt-get install libmysqlclient15off libmysqlclient15-dev mysql-client mysql-common  2>> installer.log
 sudo apt-get install libc6-dev gcc libfcgi-dev ruby1.8-dev  2>> installer.log
 sudo apt-get install libfcgi-ruby1.8 libfcgi-dev  2>> installer.log
 sudo apt-get install catdoc  2>> installer.log
 sudo apt-get install curl  2>> installer.log
 sudo apt-get install memcached  2>> installer.log
 sudo gem install rubygems-update -v 1.3.6 2>> installer.log
 sudo /var/lib/gems/1.8/bin/./update_rubygems
 sudo gem install bundler 2>> installer.log
 sudo bundle install --without development test
echo ""
echo ""
echo "############################################################################"
echo ""

LINEAS=`grep 'export PATH=/var/lib/gems/1.8/bin:$PATH' /etc/profile | wc -l`
if [ $LINEAS = 0  ]
then
  echo 'export PATH='`gem env gemdir`'/bin:$PATH'  >> /etc/profile
  echo "Cacique will add rubygems path to your system,"
  echo "please reload your profile doing 'source /etc/profile' "
  echo ""
fi

LINEAS=`grep '.gem/ruby/1.8/bin' $HOME/.bashrc | wc -l` 
if [ $LINEAS = 0 ]
then
  PATH='$PATH':$HOME/.gem/ruby/1.8/bin >> $HOME/.bashrc
  echo PATH='$PATH':$HOME/.gem/ruby/1.8/bin >> $HOME/.bashrc
fi
sudo /bin/ln -s /usr/bin/ruby1.8 /usr/bin/ruby

echo "-----------------------------------------------" >> installer.log
echo "If you need more information, please contact us to robot@mercadolibre.com"
echo "Thank you for chooose Cacique :) [ Cacique Team ]"
echo ""
echo "############################################################################"
echo ""

