#!/bin/sh --
#-*- mode: sh; coding: euc-jp -*-
# file: rotate_mysqllog.zsh
# Author: INABA Akira <inaba@k8.dion.ne.jp>
#    Created on 2004/02/25

PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/mysql/bin
IFS=' '

DATE=(`date --date=yesterday '+%Y %m %d'`)

LOGDIR=/srv/mysql/log
LOGFILE=mysql_log
LOGFILES=(mysql_log slow_log)

BACKUPDIR=$LOGDIR/${DATE[0]}/${DATE[1]}

#################################################################################
# For security, the file written mysql's root password can be read by only mysql#
# administrators.                                                               #
#################################################################################

if [ -r /etc/rc.d/rc.mysqld.conf ]; then
    MOD=`ls -l /etc/rc.d/rc.mysqld.conf | cut -f 1 -d ' '`
    if [ $MOD = "-rwx------" ]; then
        . /etc/rc.d/rc.mysqld.conf
    else
        echo "Invalid permission on /etc/rc.d/rc.mysqld.conf"
        exit 1
    fi
fi

if [ "$PASSWD" = "" ]; then
    PASSWD=toor
fi


if [ ! -d $BACKUPDIR ]; then
    mkdir -p $BACKUPDIR
    if [ $? -ne 0 ]; then
        exit 1
    fi
    sleep 1
fi

for FILE in ${LOGFILES[@]}; do
    if [ -f $LOGDIR/$FILE -a -s $LOGDIR/$FILE ]; then
        mv $LOGDIR/$FILE $BACKUPDIR/$FILE.${DATE[2]}
        if [ $? -ne 0 ]; then
            exit 1
        fi
    fi
    sleep 1
done

mysqladmin -uroot -p$PASSWD flush-logs

if [ $? -ne 0 ]; then
    exit 1
fi

for second in 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 \
                0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 60 ; do
    if [ -f $LOGDIR/$LOGFILE -a -f $BACKUPDIR/$LOGFILE.${DATE[2]} ]; then
        break;
    fi
    sleep 1
done

if [ $second -eq 60 ]; then
    echo "Cannot make sure the mysqld's flush-logs." 1>&2
    exit 1
fi
#    chmod g-w $LOGDIR/$LOGFILE
#    chgrp user $LOGDIR/$LOGFILE

for FILE in ${LOGFILES[@]}; do
    if [ -f $BACKUPDIR/$FILE.${DATE[2]} -a -s $BACKUPDIR/$FILE.${DATE[2]} ]; then
        bzip2 $BACKUPDIR/$FILE.${DATE[2]}
        if [ $? -ne 0 ]; then
            exit 1
        fi
        sleep 1
    fi
done

exit 0
