#!/bin/bash
set -e

sed -i "s|{{ BIND_ADDRESS }}|$BIND_ADDRESS|g" /etc/redis.conf
sed -i "s|{{ BIND_PORT }}|$BIND_PORT|g" /etc/redis.conf
sed -i "s|{{ REDIS_PASS }}|$REDIS_PASS|g" /etc/redis.conf
