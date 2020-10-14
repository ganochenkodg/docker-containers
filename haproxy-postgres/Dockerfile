FROM haproxytech/haproxy-debian:2.2

ENV MAX_CONN 1000
ENV FIRST_NODE 192.168.0.1
ENV SECOND_NODE 192.168.0.2

COPY ./haproxy.cfg /etc/haproxy.cfg
COPY ./haproxy-entrypoint.sh /usr/local/bin/haproxy-entrypoint.sh

CMD ["/usr/local/bin/haproxy-entrypoint.sh"]
