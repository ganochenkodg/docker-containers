FROM postgres:12.2

ENV SLACK_CHANNEL dev-backups
ENV CLUSTER_NAME pg_cluster

# special repmgr db for cluster info
ENV REPLICATION_DB replication_db
ENV REPLICATION_USER replication_user
ENV REPLICATION_PASSWORD replication_pass
ENV REPLICATION_PRIMARY_PORT 5432

ENV NODE_PRIORITY 100

ENV CONFIGS_DELIMITER_SYMBOL ,
ENV CONFIGS_ASSIGNMENT_SYMBOL :
#CONFIGS_DELIMITER_SYMBOL and CONFIGS_ASSIGNMENT_SYMBOL are used to parse CONFIGS variable
# if CONFIGS_DELIMITER_SYMBOL=| and CONFIGS_ASSIGNMENT_SYMBOL=>, valid configuration string is var1>val1|var2>val2

ENV REPMGR_MAJOR 4
ENV REPMGR_NODES_TABLE nodes
ENV REPMGR_NODE_ID_COLUMN node_id
ENV REPMGR_NODE_NAME_COLUMN node_name
ENV REPMGR_CLUSTER_SHOW_MASTER_PATTERN primary
ENV REPMGR_SHOW_NODES_TABLE show_nodes
ENV REPMGR_NODE_ID_PARAM_NAME node_id
ENV REPMGR_LOG_LEVEL_PARAM_NAME log_level
ENV REPMGR_MASTER_RESPONSE_TIMEOUT_PARAM_NAME async_query_timeout

ENV PARTNER_NODES ""
                    # List (comma separated) of all nodes in the cluster, it allows master to be adaptive on restart
                    # (can act as a new standby if new master has been already elected)

ENV MASTER_ROLE_LOCK_FILE_NAME $PGDATA/master.lock
                                                   # File will be put in $MASTER_ROLE_LOCK_FILE_NAME when:
                                                   #    - node starts as a primary node/master
                                                   #    - node promoted to a primary node/master
                                                   # File does not exist
                                                   #    - if node starts as a standby
ENV STANDBY_ROLE_LOCK_FILE_NAME $PGDATA/standby.lock
                                                  # File will be put in $STANDBY_ROLE_LOCK_FILE_NAME when:
                                                  #    - event repmgrd_failover_follow happened
                                                  # contains upstream NODE_ID
                                                  # that basically used when standby changes upstream node set by default
ENV REPMGR_WAIT_POSTGRES_START_TIMEOUT 90
                                            # For how long in seconds repmgr will wait for postgres start on current node
                                            # Should be big enough to perform post replication start which might take from a minute to a few
ENV USE_REPLICATION_SLOTS 1
                                # Use replication slots to make sure that WAL files will not be removed without beein synced to replicas
                                # Recomended(not required though) to put 0 for replicas of the second and deeper levels
ENV CLEAN_OVER_REWIND 0
                        # Clean $PGDATA directory before start standby and not try to rewind
ENV SSH_ENABLE 0
                        # If you need SSH server running on the node

#### Advanced options ####
ENV REPMGR_DEGRADED_MONITORING_TIMEOUT 5
ENV REPMGR_PID_FILE /tmp/repmgrd.pid
ENV STOPPING_LOCK_FILE /tmp/stop.pid
ENV MASTER_SYNC_LOCK_FILE /tmp/replication
ENV STOPPING_TIMEOUT 5
ENV CONNECT_TIMEOUT 2
ENV RECONNECT_ATTEMPTS 3
ENV RECONNECT_INTERVAL 5
ENV MASTER_RESPONSE_TIMEOUT 20
ENV LOG_LEVEL INFO
ENV CHECK_PGCONNECT_TIMEOUT 10
ENV REPMGR_SLOT_NAME_PREFIX repmgr_slot_
ENV LAUNCH_RECOVERY_CHECK_INTERVAL 30

RUN apt-get update --fix-missing && \
    apt-get install -y curl keepalived postgresql-12-repack ssh xinetd

RUN curl https://dl.2ndquadrant.com/default/release/get/deb | bash
RUN apt-get install -y postgresql-12-repmgr

COPY ./pgsql/bin /usr/local/bin/cluster
RUN chmod -R +x /usr/local/bin/cluster
RUN ln -s /usr/local/bin/cluster/functions/* /usr/local/bin/
COPY ./pgsql/configs /var/cluster_configs

ENV NOTVISIBLE "in users profile"

EXPOSE 5432

VOLUME /var/lib/postgresql/data
USER root

ENV KEEPALIVED_INTERFACE eth0
ENV STANDALONE false

COPY ./db_check_master.sh /usr/local/bin/db_check_master.sh
COPY ./keepalived.conf /etc/new-keepalived.conf
COPY ./config_keepalive.sh /usr/local/bin/config_keepalive.sh
COPY ./init_backup.sh /usr/local/bin/init_backup.sh
COPY ./restore_backup.sh /usr/local/bin/restore_backup.sh
COPY ./list_backup.sh /usr/local/bin/list_backup.sh
COPY ./pgkeepalive-entrypoint.sh /usr/local/bin/pgkeepalive-entrypoint.sh
COPY ./slack.sh /usr/local/bin/slack.sh
COPY ./healthcheck.sh /usr/local/bin/healthcheck.sh
COPY ./make_repack.sh /usr/local/bin/make_repack.sh
COPY ./addrights.sh /usr/local/bin/addrights.sh
COPY ./createdb.sh /usr/local/bin/createdb.sh
COPY ./fixviews.sh /usr/local/bin/fixviews.sh
COPY ./fix_table_sequences.sh /usr/local/bin/fix_table_sequences.sh
COPY ./fix_functions.sh /usr/local/bin/fix_functions.sh
COPY ./psqlservice.sh /usr/local/bin/psqlservice.sh
COPY ./xinetdpsql /etc/xinetd.d/xinetdpsql

CMD ["/usr/local/bin/pgkeepalive-entrypoint.sh"]
HEALTHCHECK CMD ["/usr/local/bin/healthcheck.sh"]
