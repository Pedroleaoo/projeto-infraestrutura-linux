#!/bin/bash
if [ -f /opt/scripts/.env ]; then
    export $(cat /opt/scripts/.env | xargs)
fi
DB_USER="$"
DB_NAME="$"
BACKUP_DIR="/tmp/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_$_$.tar.gz"
SMB_SHARE="$"
MOUNT_POINT="/mnt/backups_remote"
SMB_USER="$"
SMB_PASS="$"

mkdir -p $BACKUP_DIR
pg_dump -U $DB_USER -F t $DB_NAME > "$BACKUP_DIR/db.tar"
tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$BACKUP_DIR" db.tar
rm "$BACKUP_DIR/db.tar"

mkdir -p $MOUNT_POINT
mount -t cifs -o username="$SMB_USER",password="$SMB_PASS" $SMB_SHARE $MOUNT_POINT
if [ $? -eq 0 ]; then
    cp "$BACKUP_DIR/$BACKUP_FILE" "$MOUNT_POINT/"
    umount $MOUNT_POINT
fi
find $BACKUP_DIR -type f -mtime +7 -exec rm -f {} \;
