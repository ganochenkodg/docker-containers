#!/bin/bash

echo ">>> Configuring redis..."
/usr/local/bin/config_redis.sh

echo ">>> Running redis..."
redis-server /etc/redis.conf 2>&1
