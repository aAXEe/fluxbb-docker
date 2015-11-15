#!/bin/sh
set -e

PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="PHP5 FastCGI Process Manager"
NAME=php5-fpm
DAEMON=/usr/sbin/$NAME

[ -r /etc/default/$NAME ] && . /etc/default/$NAME
/usr/lib/php5/php5-fpm-checkconf
php5-fpm --nodaemonize --fpm-config /etc/php5/fpm/php-fpm.conf
