#!/bin/bash

ssh -i /backupkeys/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $BACKUP_USERNAME@$BACKUP_HOST "ls -lh $BACKUP_PATH" 2>&1
