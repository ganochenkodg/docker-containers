#!/bin/bash

export APP_SLACK_USERNAME="Restore backup"
export APP_SLACK_ICON_EMOJI="mysql"
SUCCESS=""
DBLIST=$2

if [ -z "$1" ]; then
    echo "Usage: restore_backup \"backup name\" \"db name\""
    echo "backup name - looks like backup-2019-10-17-13-50"
    echo "You can found it on $BACKUP_HOST in $BACKUP_PATH"
    echo "db name - optional, list of db separated by spaces"
    echo "for example \"database1.sql database2.sql\""
    exit 1
fi
export BACKUP_NAME=$1


if [ -z "$DBLIST" ]; then
    echo "You want to restore full $1"
else
    echo "You want to restore $DBLIST"
fi

read -p "Are you sure you want to continue? <y/n> " prompt
if [[ $prompt =~ [yY](es)* ]]; then
    echo "Starting..."
else
    echo "Cancelling..."
    exit 1
fi

function downloadBackup() {
    echo "Downloading $BACKUP_NAME"
    RESULT=$(scp -i /backupkeys/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $BACKUP_USERNAME@$BACKUP_HOST:$BACKUP_PATH/$BACKUP_NAME.tar.gz.enc  /dbbackup 2>&1)
    if [ $? -ne 0 ]; then
        echo Fail to download backup
        /usr/local/bin/slack.sh "#$SLACK_CHANNEL" ":x: Fail to download backup \\n \`\`\`$(echo $RESULT | tr -d \']\"[\')\`\`\`"
    else
        echo "Succecfully downloaded $BACKUP_NAME"
    fi
}

function encryptBackup() {
    RESULT=$(openssl aes-256-cbc -d -a -in /dbbackup/$BACKUP_NAME.tar.gz.enc -pass env:OPENSSL_PASSWORD | tar xz -C /dbbackup 2>&1)
    if [ $? -ne 0 ]; then
        echo Fail to encrypt backup
        /usr/local/bin/slack.sh "#$SLACK_CHANNEL" ":x: Fail to encrypt backup \\n \`\`\`$(echo $RESULT | tr -d \']\"[\')\`\`\`"
        exit 1
    else
        echo "Succecfully encrypted $BACKUP_NAME"
    fi
}

function restoreDumps() {
    cd /dbbackup
    if [ -z "$DBLIST" ]; then
        DBLIST=$(ls *.sql)
    fi
    for i in $DBLIST; do
        echo Try to restore $i
        RESULT=$(mysql -uroot -p"$MYSQL_ROOT_PASSWORD" < $i 2>&1)
        if [ $? -ne 0 ]; then
            echo -e "Fail to restore $i\n$RESULT"
            /usr/local/bin/slack.sh "#$SLACK_CHANNEL" ":x: Fail to restore $i on $NODE_NAME \\n \`\`\`$(echo $RESULT | tr -d \']\"[\')\`\`\`"
        else
            SUCCESS+="$i "
        fi
    done
    if [ -z "$SUCCESS" ]; then
        echo "No one DB restored"
    else
        SUCCESS=$(echo $SUCCESS | sed 's/\.sql//g')
        echo "Successfully restored: $SUCCESS"
        /usr/local/bin/slack.sh "#$SLACK_CHANNEL" ":heavy_check_mark: Successfully restored \\n \`\`\`$SUCCESS\`\`\`\\n From $BACKUP_NAME on $NODE_NAME"
    fi
}

#make directory for backup
mkdir -p /dbbackup

downloadBackup
encryptBackup
restoreDumps
echo Cleanup /dbbackup
rm -rf /dbbackup/*
