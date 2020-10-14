FROM mysql:5.7

ENV SLACK_CHANNEL dev-backups
RUN apt-get update -y
RUN apt-get install -y --no-install-recommends curl openssh-client ca-certificates

COPY ./init_backup.sh /usr/local/bin/init_backup.sh
COPY ./restore_backup.sh /usr/local/bin/restore_backup.sh
COPY ./list_backup.sh /usr/local/bin/list_backup.sh
COPY ./slack.sh /usr/local/bin/slack.sh
