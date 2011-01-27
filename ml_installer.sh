#!/bin/bash
 
 #######################################################################
 ####   List of gems that are used for functions or scripts in ML   ####
 #######################################################################
 
 echo "===============================================" >> installer.log
 date>> installer.log
 echo "-----------------------------------------------" >> installer.log

 sudo gem sources -a http://gems.github.com   2>> installer.log
 sudo gem install mail  2>> installer.log
 sudo gem install pony 2>> installer.log
 sudo gem install json 2>> installer.log
 sudo gem install ruby-oci8 -v 1.0.6 2>> installer.log
 sudo gem install soap4r 2>> installer.log
 sudo gem install jira4r 2>> installer.log
 sudo gem install hoptoad_notifier 2>> installer.log
 echo "-----------------------------------------------" >> installer.log
