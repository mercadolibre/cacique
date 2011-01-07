#!/bin/bash
case "$1" in
  start)
	/usr/bin/memcached -P /tmp/memcached.pid -u cacique  -d 
	sleep 1
  ;;
  stop)
	/bin/rm /tmp/memcached.pid
	kill `pgrep memcached`
  ;;
esac
