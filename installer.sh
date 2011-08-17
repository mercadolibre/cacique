#!/bin/bash
 echo $USER
 echo "===============================================" >> installer.log
 date>> installer.log
 echo "-----------------------------------------------" >> installer.log
 sudo apt-get -y install git-core 2>> installer.log
 sudo apt-get -y install ruby 2>> installer.log
 sudo apt-get -y install ruby-dev 2>> installer.log
 sudo apt-get -y install rubygems 2>> installer.log
 sudo apt-get -y install build-essential 2>> installer.log
 sudo apt-get -y install libxslt1-dev 2>> installer.log
 sudo apt-get -y install libopenssl-ruby 2>> installer.log
 sudo apt-get -y install graphviz 2>> installer.log
 sudo apt-get -y install libmysql-ruby 2>> installer.log
 sudo apt-get -y install apache2 libcurl4-openssl-dev libssl-dev apache2-prefork-dev libapr1-dev libaprutil1-dev 2>> installer.log
 sudo apt-get -y install mysql-server 2>> installer.log
 sudo apt-get -y install libmysqlclient-dev mysql-client 2>> installer.log
 sudo apt-get -y install libfcgi-ruby1.8 libfcgi-dev 2>> installer.log
 sudo apt-get -y install catdoc 2>> installer.log
 sudo apt-get -y install curl 2>> installer.log
 sudo apt-get -y install memcached 2>> installer.log
 sudo gem install -V rubygems-update -v 1.3.6 2>> installer.log
 sudo /var/lib/gems/1.8/bin/./update_rubygems
 sudo gem install -V bundler 2>> installer.log
 bundle install --without development test
echo ""
echo ""
echo "############################################################################"
echo ""

LINEAS=`cat /etc/profile | grep gems | wc -l`
if [ $LINEAS = 0  ]
then
  echo "Adding export PATH=/var/lib/gems/1.8/bin:$PATH to the global profile file (/etc/profile)"
  echo "so it exports the bin path for the global ruby gems"
  echo "export PATH=/var/lib/gems/1.8/bin:\$PATH"  >> /etc/profile
  echo "Cacique will add rubygems path to your system,"
  echo "please reload your profile doing 'source /etc/profile' "
  echo ""
fi

LINEAS=`grep '.gem/ruby/1.8/bin' $HOME/.bashrc | wc -l` 
if [ $LINEAS = 0 ]
then
  echo "Adding export PATH=$HOME/.gem/ruby/1.8/bin:$PATH to the user bash resource file"
  echo "so it handles the user ruby gems installation"
  echo "export PATH=$HOME/.gem/ruby/1.8/bin:\$PATH" >> $HOME/.bashrc
  echo "Please log out and re login or source your .bashrc to see the changes"
fi

echo "-----------------------------------------------" >> installer.log
echo "If you need more information, please contact us to robot@mercadolibre.com"
echo "Thank you for chooose Cacique :) [ Cacique Team ]"
echo ""
echo "############################################################################"
echo ""
