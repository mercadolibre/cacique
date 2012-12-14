#!/bin/bash

wrunning=`ps aux | grep workling | grep -v grep | wc -l`

if [ "$wrunning" != "0" ]
then

dialog --backtitle "CACIQUE" --title "ATENTION!" --yesno \
"You have $wrunning Worker/s running
     Do you want to continue?
" 8 30

ans=$?
fi



if [ "$ans" != "1" ]
then

dialog 	  --backtitle "CACIQUE" \
	  --title "CACIQUE WORKERS" \
	  --form "Enter amount of Workers to Start

  Remember: Each Worker consume 
  a lot of machine memory.
" \
12 40 0 \
	"QUANTITY:"  1 2  "1"  1 13  3 0 2>tempfile

wcant=`awk 'NR==1' tempfile`

COUNT=0
(
while [ $COUNT -lt $wcant ]
do
let COUNT=COUNT+1
script/workling_client start --number $COUNT &

 dialog --backtitle "CACIQUE" --title "CACIQUE WORKERS" --infobox \
'        Starting Worker '$COUNT'
' 3 40; sleep 1

sleep 1
done
)

fi

rm tempfile
clear
