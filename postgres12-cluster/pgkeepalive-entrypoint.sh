#!/bin/bash
set -e

if [ "$STANDALONE" == "false" ]; then
    echo ">>> Configuring keepalive..."
    /usr/local/bin/config_keepalive.sh

    echo ">>> Running keepalive..."
    exec keepalived --vrrp --dont-fork --log-console --use-file=/etc/new-keepalived.conf >>/var/log/container/keepalived.log 2>&1 &
fi
xinetd -dontfork &
trap "rm -f /var/run/keepalived.pid & ip addr del $FLOAT_IP/32 dev $KEEPALIVED_INTERFACE" SIGINT SIGTERM
/usr/local/bin/cluster/entrypoint.sh >>/var/log/container/pg_repmgr.log 2>&1 &
wait
