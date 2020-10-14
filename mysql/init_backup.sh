#!/bin/bash

export APP_SLACK_USERNAME="Create backup"
export APP_SLACK_ICON_EMOJI="mysql"
SUCCESS=""

function backupDB() {
    if [ -z "$1" ]; then
        echo "Backups all DB"
        export DBLIST=$(getDBList)
    else
        export DBLIST=$1
    fi
    for i in $DBLIST; do
        echo Try to backup $i
        RESULT=$(mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" -B $i > /dbbackup/$CURRENT_TIME/$i.sql)
        if [ $? -ne 0 ]; then
            echo -e "Fail to backup $i\n$RESULT"
            /usr/local/bin/slack.sh "#$SLACK_CHANNEL" ":x: Fail to backup $i on $NODE_NAME \\n \`\`\`$(echo $RESULT | tr -d \']\"[\')\`\`\`"
        else
            SUCCESS+="$i "
        fi
    done
}

function compressDB() {
    if [ -z "$SUCCESS" ]; then
        echo "No one DB dumped, exit"
        exit 1
    else
        cd /dbbackup/$CURRENT_TIME
        echo Start compress and encrypt dumps
        tar -zcvf /dbbackup/backup-$CURRENT_TIME.tar.gz ./*sql
        openssl aes-256-cbc -salt -a -in /dbbackup/backup-$CURRENT_TIME.tar.gz -out /dbbackup/backup-$CURRENT_TIME.tar.gz.enc -pass env:OPENSSL_PASSWORD
    fi
}

function sendBackup() {
    RESULT=$(scp -i /backupkeys/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /dbbackup/backup-$CURRENT_TIME.tar.gz.enc $BACKUP_USERNAME@$BACKUP_HOST:$BACKUP_PATH 2>&1)
    if [ $? -ne 0 ]; then
        echo Fail to send backup
        /usr/local/bin/slack.sh "#$SLACK_CHANNEL" ":x: Fail to send backup \\n \`\`\`$(echo $RESULT | tr -d \']\"[\')\`\`\`"
    else
        echo "Succecfully backuped: $SUCCESS"
        /usr/local/bin/slack.sh "#$SLACK_CHANNEL" ":heavy_check_mark: Successfully backuped \\n \`\`\`$SUCCESS\`\`\`\\n at $BACKUP_PATH/backup-$CURRENT_TIME.tar.gz.enc on $NODE_NAME"
    fi
}

function getDBList() {
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e 'show databases;'|tail +2|grep -v schema
}

#make directory for backup
CURRENT_TIME=$(date "+%Y-%m-%d-%H-%M")
mkdir -p /dbbackup/$CURRENT_TIME

backupDB $1
compressDB
sendBackup
echo Cleanup /dbbackup
rm -rf /dbbackup/*
