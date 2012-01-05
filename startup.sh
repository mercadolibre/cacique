#!/bin/bash

 dialog --backtitle "CACIQUE" --msgbox \
'
 ===================================================
                   CACIQUE STARTUP                 
 ---------------------------------------------------

          In tihs step you select and start        
               all CACIQUE services             

 ===================================================
' 13 58

dialog --backtitle "CACIQUE" --title "CACIQUE STARTUP"\
       --checklist  "Select Process to Start:" 10 40 3 \
        1 WORKERS off \
        2 RAKE-JOBS off \
        3 TASK-MANNAGER off 2>tempfile

choice1=`cat tempfile | grep 1 | grep -v grep | wc -l`
choice2=`cat tempfile | grep 2 | grep -v grep | wc -l`
choice3=`cat tempfile | grep 3 | grep -v grep | wc -l`

if [ "$choice1" == "1" ]
then
./workers.sh
fi

if [ "$choice2" == "1" ]
then
 dialog --backtitle "CACIQUE" --title "CACIQUE WORKERS" --infobox \
'         Starting RAKE-JOBS
' 3 40; sleep 1
rake jobs:work RAILS_ENV=production &
fi

if [ "$choice3" == "1" ]
then
 dialog --backtitle "CACIQUE" --title "CACIQUE WORKERS" --infobox \
'         Starting TASK-MANNAGER
' 3 40; sleep 1
script/mannager.rb &
fi

rm tempfile
clear
