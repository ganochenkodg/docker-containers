#!/bin/bash

export APP_SLACK_USERNAME="pg_repack"
export APP_SLACK_ICON_EMOJI="postgresql"
SUCCESS=""

/usr/local/bin/db_check_master.sh
if [ $? -ne 0 ]; then
    echo "You try to pg_repack on slave, stop"
    exit 1
fi

read -p "Are you sure you want to continue? <y/n> " prompt
if [[ $prompt =~ [yY](es)* ]]; then
    echo "Starting..."
else
    echo "Cancelling..."
    exit 1
fi

function getDBList() {
    psql -U $POSTGRES_USER -t -c "SELECT datname FROM pg_database WHERE datname NOT LIKE 'repmgr' AND datname NOT LIKE 'template%' AND datname NOT LIKE 'postgres';"
}

function repackDB() {
    export DBLIST=$(getDBList)
    for i in $DBLIST; do
        echo Try to repack $i
        RESULT=$(gosu $POSTGRES_USER pg_repack -d $i -j 4 2>&1)
        if [ $? -ne 0 ]; then
            echo -e "Fail to repack $i\n$RESULT"
            /usr/local/bin/slack.sh "#dev-backups" ":x: Fail to repack $i on $NODE_NAME \\n \`\`\`$(echo $RESULT | tr -d \']\"[\')\`\`\`"
        else
            SUCCESS+="$i "
        fi
    done
    /usr/local/bin/slack.sh "#dev-backups" ":heavy_check_mark: Successfully repacked \\n \`\`\`$SUCCESS\`\`\`\\n on $NODE_NAME"

}

repackDB
