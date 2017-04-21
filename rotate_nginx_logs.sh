#!/bin/bash --
#-*- mode: sh; coding: utf-8 -*-
# file: rotate_nginx_logs.sh
#    Created:       <2016/08/10 14:20:17>
#    Last Modified: <2017/04/21 15:47:30>

/usr/bin/env -
IFS=' '
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

NGINX=/opt/nginx/sbin/nginx

YEAR=`date -d yesterday +%Y`
MONTH=`date -d yesterday +%m`
DAY=`date -d yesterday +%d`

DIRS=( \
    '/var/log/nginx'
    '/srv/example.com/httpd/logs'
    '/srv/example.jp/httpsd/logs'
)

for DIR in ${DIRS[@]}; do
    BACKUPDIR="$DIR/$YEAR/$MONTH"
    if [ ! -d $BACKUPDIR ]; then
        mkdir -p $BACKUPDIR
        if [ $? != 0 ]; then
            exit 1
        fi
    fi
    for FILE in $DIR/*log; do
        if [ -e $FILE ]; then
            FILE_WITHOUT_DIR=`echo $FILE | awk -F/ '{print $NF}'`
            BACKUPFILE="$BACKUPDIR/$FILE_WITHOUT_DIR.$YEAR$MONTH$DAY"
            if [ ! -e $BACKUPFILE ]; then
                mv $FILE $BACKUPFILE
            fi
        fi
    done
done

$NGINX -s reopen
if [ $? != 0 ]; then
    exit 1
fi
