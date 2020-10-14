FROM redis:6.0.6-buster

ENV REDIS_PASS password
ENV BIND_ADDRESS 127.0.0.1
ENV BIND_PORT 6379
RUN mkdir -p /var/log/container
WORKDIR /var/redis/6379
COPY ./config_redis.sh /usr/local/bin/config_redis.sh
COPY ./healthcheck.sh /usr/local/bin/healthcheck.sh
COPY ./redis-entrypoint.sh /usr/local/bin/redis-entrypoint.sh
COPY ./redis.conf /etc/redis.conf

CMD ["/usr/local/bin/redis-entrypoint.sh"]
HEALTHCHECK CMD ["/usr/local/bin/healthcheck.sh"]
