#!/bin/bash

CHECK=$(redis-cli -a "$REDIS_PASS" -h $BIND_ADDRESS -p $BIND_PORT info | awk -F: '/^role:/ {sub(/\r/,""); print $2}')

if [ "$CHECK" = "master" ]; then
    exit 0
else
    exit 1
fi
