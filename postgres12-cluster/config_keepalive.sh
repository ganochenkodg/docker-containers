#!/bin/bash
set -e

sed -i "s|{{ NODE_NAME }}|$NODE_NAME|g" /etc/new-keepalived.conf
sed -i "s|{{ OTHER_NODE_NAME }}|$OTHER_NODE_NAME|g" /etc/new-keepalived.conf
sed -i "s|{{ KEEPALIVED_INTERFACE }}|$KEEPALIVED_INTERFACE|g" /etc/new-keepalived.conf
sed -i "s|{{ FLOAT_IP }}|$FLOAT_IP|g" /etc/new-keepalived.conf
