#!/bin/bash

if ping="$(redis-cli -a "$REDIS_PASS" -h $BIND_ADDRESS -p $BIND_PORT ping)" && [ "$ping" = 'PONG' ]; then
    exit 0
else
    exit 1
fi
