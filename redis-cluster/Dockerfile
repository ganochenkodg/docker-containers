FROM redis:4.0.14-buster

RUN apt-get update -y --force-yes
RUN apt-get install -y --no-install-recommends keepalived curl
ENV KEEPALIVED_INTERFACE eth0

ENV REDIS_PASS password
ENV BIND_ADDRESS 127.0.0.1
ENV BIND_PORT 6379
ENV ISSLAVE no
COPY ./redis_check_master.sh /usr/local/bin/redis_check_master.sh
COPY ./keepalived.conf /etc/redis-keepalived.conf
COPY ./config_keepalive.sh /usr/local/bin/config_keepalive.sh
COPY ./config_redis.sh /usr/local/bin/config_redis.sh
COPY ./healthcheck.sh /usr/local/bin/healthcheck.sh
COPY ./redis-entrypoint.sh /usr/local/bin/redis-entrypoint.sh
COPY ./redis.conf /etc/redis.conf

CMD ["/usr/local/bin/redis-entrypoint.sh"]
HEALTHCHECK CMD ["/usr/local/bin/healthcheck.sh"]
