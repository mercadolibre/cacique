#!/bin/bash
case "$1" in
  start)
        /usr/bin/memcached -P /tmp/memcached.pid -u cacique  -d -l 127.0.0.1
        sleep 1
  ;;
  stop)
        /bin/rm /tmp/memcached.pid
        kill `pgrep memcached`
  ;;
esac
