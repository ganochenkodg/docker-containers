#!/bin/bash
set -e

echo ">>> Configuring redis..."
/usr/local/bin/config_redis.sh

trap "rm -f /var/run/keepalived.pid & ip addr del $FLOAT_IP/32 dev $KEEPALIVED_INTERFACE" SIGINT SIGTERM
echo ">>> Running redis..."
redis-server /etc/redis.conf 2>&1 &
if [[ $ISSLAVE =~ [yY](es)* ]];  then
    echo ">>> Make redis replica of $OTHER_NODE_NAME"
    until /usr/local/bin/healthcheck.sh;do
        sleep 2
        echo "Retry Redis ping... "
    done
    redis-cli -a "$REDIS_PASS" -h $BIND_ADDRESS -p $BIND_PORT SLAVEOF $OTHER_NODE_NAME $BIND_PORT
fi

echo ">>> Configuring keepalive..."
/usr/local/bin/config_keepalive.sh

echo ">>> Running keepalive..."
exec keepalived --vrrp --dont-fork --log-console --use-file=/etc/redis-keepalived.conf >>/var/log/container/keepalived.log 2>&1 &

wait
