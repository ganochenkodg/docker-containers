#!/bin/bash

export APP_SLACK_USERNAME="Restore backup"
export APP_SLACK_ICON_EMOJI="postgresql"
SUCCESS=""
DBLIST=$2
TMPREST=$3

if [ -z "$1" ]; then
    echo "Usage: restore_backup \"backup name\" \"db name\" --tmp"
    echo "backup name - looks like backup-2019-10-17-13-50"
    echo "You can found it on $BACKUP_HOST in $BACKUP_PATH"
    echo "db name - optional, list of db separated by spaces"
    echo "for example \"database1.sql database2.sql\""
    echo "--tmp - optional, restore one dump to tmp_restore_db"
    exit 1
fi
export BACKUP_NAME=$1

/usr/local/bin/db_check_master.sh
if [ $? -ne 0 ]; then
    echo "You try to restore backup on slave, stop"
    exit 1
fi

if [ -z "$DBLIST" ]; then
    echo "You want to restore full $1"
else
    if [ "$TMPREST" != "--tmp" ]; then
        echo "You want to restore $DBLIST"
    else
        if echo $DBLIST | grep -q " "; then
            echo "You must use --tmp with one sql dump"
            exit 1
        else
            echo "You want to restore $DBLIST to tmp_restore_db"
        fi
    fi
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
        psql -U $POSTGRES_USER -f /dbbackup/roles.sql
        DBLIST=$(ls *.sql)
    fi
    for i in $DBLIST; do
        echo Try to restore $i
        if [ "$TMPREST" == "--tmp" ]; then
            export CURDB="tmp_restore_db"
        else
            export CURDB=$(echo $i | sed 's/.sql//g')
        fi
        if [ "$i" != "roles.sql" ]; then
            psql -U $POSTGRES_USER -c "SELECT pg_terminate_backend(pid) \
            FROM pg_stat_activity WHERE datname = '$CURDB';"
            psql -U $POSTGRES_USER -c "DROP DATABASE $CURDB;"
            psql -U $POSTGRES_USER -c "CREATE DATABASE $CURDB \
            WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';"
        else
            export CURDB="postgres"
        fi
        RESULT=$(psql -U $POSTGRES_USER -d $CURDB -f $i 2>&1)
        if [ $? -ne 0 ]; then
            echo -e "Fail to restore $i\n$RESULT"
            /usr/local/bin/slack.sh "#$SLACK_CHANNEL" ":x: Fail to restore $i on $NODE_NAME \\n \`\`\`$(echo $RESULT | tr -d \']\"[\')\`\`\`"
        else
            SUCCESS+="$i "
        fi
    done
    if [ -z "$SUCCESS" ]; then
        echo "No one DB dumped"
    else
        if [ "$TMPREST" == "--tmp" ]; then
            SUCCESS+=" to tmp_restore_db"
        fi
        SUCCESS=$(echo $SUCCESS | sed 's/.sql//g')
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
