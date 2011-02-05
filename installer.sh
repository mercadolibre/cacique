#!/bin/bash
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
#Para la suite_programada y comando
#Setea los path para que los bin instalados con rubyGems puedan ser ejecutado desde la consola
#tantos los instalados para todos los usuarios como los instalados por el usuario

 sudo apt-get install memcached  2>> installer.log
 sudo gem install rubygems-update  2>> installer.log
 sudo update_rubygems  2>> installer.log
LINEAS=`grep 'export PATH=/var/lib/gems/1.8/bin:$PATH' /etc/bash.bashrc | wc -l`

echo $LINEAS
if [ $LINEAS = 0  ]
echo "############################se modifica el bashrc######################################"
then
  echo 'export PATH=/var/lib/gems/1.8/bin:$PATH' >> /etc/bash.bashrc
fi

LINEAS=`grep '.gem/ruby/1.8/bin' $HOME/.bashrc | wc -l` 
if [ $LINEAS = 0 ]
then
  PATH='$PATH':$HOME/.gem/ruby/1.8/bin >> $HOME/.bashrc
  echo PATH='$PATH':$HOME/.gem/ruby/1.8/bin >> $HOME/.bashrc
fi

sudo gem install rubygems-update    2>> installer.log
sudo update_rubygems  2>> installer.log
sudo gem sources -a http://gems.github.com --no-ri --no-rdoc  2>> installer.log
sudo gem install  mongrel --no-ri --no-rdoc 2>> installer.log
sudo gem install  daemons -v 1.0.10 --no-ri --no-rdoc 2>> installer.log
sudo gem install  haml -v 2.2.2 --no-ri --no-rdoc  2>> installer.log
sudo gem install  hoe -v 2.3.2 --no-ri --no-rdoc 2>> installer.log
sudo gem install  hpricot -v 0.8.1 --no-ri --no-rdoc 2>> installer.log
sudo gem install  mechanize -v 0.9.3 --no-ri --no-rdoc 2>> installer.log
sudo gem install  memcache-client --no-ri --no-rdoc 2>> installer.log
sudo gem install  nokogiri --no-ri --no-rdoc  2>> installer.log
sudo gem install  polyglot --no-ri --no-rdoc 2>> installer.log
sudo gem install  ruby-graphviz --no-ri --no-rdoc 2>> installer.log
sudo gem install  ruby-ole --no-ri --no-rdoc 2>> installer.log
sudo gem install  rubyforge --no-ri --no-rdoc 2>> installer.log
sudo gem install  s4t-utils --no-ri --no-rdoc 2>> installer.log
sudo gem install  searchlogic --no-ri --no-rdoc  2>> installer.log
sudo gem install  Selenium --no-ri --no-rdoc 2>> installer.log
sudo gem install  spreadsheet --no-ri --no-rdoc 2>> installer.log
sudo gem install  SyslogLogger --no-ri --no-rdoc 2>> installer.log
sudo gem install  treetop --no-ri --no-rdoc 2>> installer.log
sudo gem install  user-choices --no-ri --no-rdoc 2>> installer.log
sudo gem install  xml-simple -v 1.0.12 --no-ri --no-rdoc 2>> installer.log
sudo gem install  mislav-will_paginate --no-ri --no-rdoc 2>> installer.log
sudo gem install  vestal_versions --no-ri --no-rdoc 2>> installer.log
sudo gem install  calendar_date_select --no-ri --no-rdoc 2>> installer.log
sudo gem install  rspec-rails --no-ri --no-rdoc 2>> installer.log
sudo gem install  rspec --no-ri --no-rdoc 2>> installer.log
sudo gem install  ruby-openid --no-ri --no-rdoc 2>> installer.log
sudo gem install  thin --no-ri --no-rdoc 2>> installer.log
sudo gem install  test-spec --no-ri --no-rdoc 2>> installer.log
sudo gem install  rake --no-ri --no-rdoc 2>> installer.log
sudo gem install  mechanize  --no-ri --no-rdoc 2>> installer.log
sudo gem install  laserlemon-vestal_versions --no-ri --no-rdoc 2>> installer.log
sudo gem install  mysql ––with-mysql-config=/usr/bin/mysql_config --no-ri --no-rdoc  2>> installer.log
sudo gem install  net-ssh --no-ri --no-rdoc 2>> installer.log
sudo gem install  locale --no-ri --no-rdoc 2>> installer.log
sudo gem install  locale_rails -v 2.0.5 --no-ri --no-rdoc 2>> installer.log

echo "We had a problem with the gem "locale_rails" to fix it is to apply a patch. You agree? (Y | N):"
echo ">> "
read choice
echo "Applying patch..."
if [ $choice = "Y" ];then
        sudo cp extras/i18n.rb /var/lib/gems/1.8/gems/locale_rails-2.0.5/lib/locale_rails/ 2>> installer.log
else
        if [ $choice = "y" ];then
                sudo cp extras/i18n.rb /var/lib/gems/1.8/gems/locale_rails-2.0.5/lib/locale_rails/ 2>> installer.log
        fi
fi
echo "Done patch."
sudo gem install  gettext gettext_activerecord gettext_rails --no-ri --no-rdoc 2>> installer.log
sudo gem install  camping  --no-ri --no-rdoc 2>> installer.log
sudo gem uninstall rails actionmailer actionpack activemodel activerecord activeresource activesupport composite_primary_keys #I need delete rails 3
sudo gem install rails -v 2.3.5 2>> installer.log
sudo gem install composite_primary_keys -v 2.3.5 --no-ri --no-rdoc
sudo gem install  passenger --no-ri --no-rdoc 2>> installer.log
sudo gem install  prawn --no-ri --no-rdoc 2>> installer.log
sudo gem install  starling --no-ri --no-rdoc 2>> installer.log
sudo mkdir -p `pwd`/tmp/
sudo chmod 744 `pwd`/tmp/ -R
echo "-----------------------------------------------" >> installer.log
