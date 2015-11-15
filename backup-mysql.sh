#!/bin/bash

set -e

DAYS_TO_KEEP=$(( 14 - 1))
TARGET_DIR=/data/backup

# *sigh*
MYSQL_DB=$(php5 -r "$(grep db_name  /data/conf/config.php; echo 'print $db_name;';)")
MYSQL_HOST=$(php5 -r "$(grep db_host /data/conf/config.php; echo 'print $db_host;';)")
MYSQL_USER=$(php5 -r "$(grep db_username /data/conf/config.php; echo 'print $db_username;';)")
MYSQL_PASSWD=$(php5 -r "$(grep db_password /data/conf/config.php; echo 'print $db_password;';)")

echo "Backing up fluxbb database…"

FILENAME=fluxbb-$(date '+%Y%m%d').sql.xz
TARGET_FILE=$TARGET_DIR/$FILENAME
nice -n19 mysqldump -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWD $MYSQL_DB --opt -c | nice -n19 xz -c > $TARGET_FILE
md5sum $TARGET_FILE > $TARGET_FILE.md5sum
chmod 600 $TARGET_DIR/*.sql.xz

echo "Purging old backups…"

find $TARGET_DIR -type f -mtime +$DAYS_TO_KEEP -exec rm -v {} \;

echo "done!"
