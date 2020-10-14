#!/bin/bash
set -e

sed -i "s|{{ FIRST_NODE }}|$FIRST_NODE|g" /etc/haproxy.cfg
sed -i "s|{{ SECOND_NODE }}|$SECOND_NODE|g" /etc/haproxy.cfg
sed -i "s|{{ MAX_CONN }}|$MAX_CONN|g" /etc/haproxy.cfg

haproxy -f /etc/haproxy.cfg
