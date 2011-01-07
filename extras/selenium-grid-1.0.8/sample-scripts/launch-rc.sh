#!/bin/bash

export PATH=/usr/lib/firefox:${PATH}
ant -Dport=$1 launch-remote-control
