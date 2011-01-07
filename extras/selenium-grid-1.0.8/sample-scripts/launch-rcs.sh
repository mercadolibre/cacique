#!/bin/sh

for port in 5551 5552 5553 5554 5555 5556 5557 5558 5559 5560 ; do
  gnome-terminal --title "RC ${port}" -e "./launch-rc.sh ${port}"
done
