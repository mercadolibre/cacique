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

sudo gem install rubygems-update  2>> installer.log
sudo update_rubygems  2>> installer.log
sudo gem sources -a http://gems.github.com   2>> installer.log
sudo gem install  mongrel  2>> installer.log
sudo gem install  rails -v 2.3.5  2>> installer.log
sudo gem install  commonwatir -v 1.6.2  2>> installer.log
sudo gem install  daemons -v 1.0.10  2>> installer.log
sudo gem install  eventmachine -v 0.12.8  2>> installer.log
sudo gem install  god -v 0.7.13  2>> installer.log
sudo gem install  haml -v 2.2.2  2>> installer.log
sudo gem install  hoe -v 2.3.2  2>> installer.log
sudo gem install  hpricot -v 0.8.1  2>> installer.log
sudo gem install  mechanize -v 0.9.3  2>> installer.log
sudo gem install  memcache-client  2>> installer.log
sudo gem install  nokogiri   2>> installer.log
sudo gem install  polyglot  2>> installer.log
sudo gem install  ruby-graphviz  2>> installer.log
sudo gem install  ruby-ole  2>> installer.log
sudo gem install  rubyforge  2>> installer.log
sudo gem install  s4t-utils 2>> installer.log
sudo gem install  searchlogic   2>> installer.log
sudo gem install  Selenium  2>> installer.log
sudo gem install  spreadsheet  2>> installer.log
sudo gem install  starling-starling  2>> installer.log
sudo gem install  SyslogLogger  2>> installer.log
sudo gem install  treetop  2>> installer.log
sudo gem install  user-choices  2>> installer.log
sudo gem install  xml-simple -v 1.0.12  2>> installer.log
sudo gem install  mislav-will_paginate  2>> installer.log
sudo gem install  rak  2>> installer.log
sudo gem install  annotate-models  2>> installer.log
sudo gem install  Selenium  2>> installer.log
sudo gem install  polyglot  2>> installer.log
sudo gem install  treetop  2>> installer.log
sudo gem install  ruby-graphviz  2>> installer.log
sudo gem install  vestal_versions  2>> installer.log
sudo gem install  calendar_date_select  2>> installer.log
sudo gem install  pdf-writer  2>> installer.log
sudo gem install  rspec-rails  2>> installer.log
sudo gem install  rspec  2>> installer.log
sudo gem install  ruby-openid  2>> installer.log
sudo gem install  thin  2>> installer.log
sudo gem install  rcov  2>> installer.log
sudo gem install  ruby-debug  2>> installer.log
sudo gem install  test-spec  2>> installer.log
sudo gem install  rake  2>> installer.log
sudo gem install  mechanize  2>> installer.log
sudo gem install  nokogiri  2>> installer.log
sudo gem install  god   2>> installer.log
sudo gem install  laserlemon-vestal_versions  2>> installer.log
sudo gem install  mysql ––with-mysql-config=/usr/bin/mysql_config   2>> installer.log
sudo gem install  composite_primary_keys  2>> installer.log
sudo gem install  net-ssh  2>> installer.log
sudo gem install  locale 2>> installer.log
sudo gem install  locale_rails -v 2.0.5 2>> installer.log

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
sudo gem install  gettext gettext_activerecord gettext_rails  2>> installer.log
sudo gem install  camping  2>> installer.log
sudo gem uninstall rails actionmailer actionpack activemodel activerecord activeresource activesupport composite_primary_keys #I need delete rails 3
sudo gem install rails -v 2.3.5 2 2>> installer.log
sudo gem install composite_primary_keys -v 2.3.5
sudo gem install  passenger  2>> installer.log
sudo gem install  prawn  2>> installer.log
sudo gem install  starling 2>> installer.log

echo "-----------------------------------------------" >> installer.log
