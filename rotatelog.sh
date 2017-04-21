#!/bin/sh --
# -*- mode: sh; coding: euc-jp -*-
# file: rotlog.sh
# Author: INABA Akira <inaba@k8.dion.ne.jp>
# Created on 2004/01/27

PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

DATE=(`date --date=yesterday '+%Y %m %d'`)

# Check distributions.
# Only Slackware and RedHat.
# If you uses Debian, Suse, or *BSD, edit this.
if [ -f /etc/slackware-version ]; then
    LOGFILES=(messages maillog syslog secure ntp.log cron lsyncd_log local0 local1 local2 local3 local4 local5 local6 local7)
elif [ -f /etc/redhat-release ]; then
    LOGFILES=(messages maillog secure cron lsyncd_log local0 local1 local2 local3 local4 local5 local6 local7)
else
    LOGFILES=(messages maillog lsyncd_log local0 local1 local2 local3 local4 local5 local6 local7)
fi

LOGDIR='/var/log'
BACKUPDIR="$LOGDIR/${DATE[0]}/${DATE[1]}"

RET=0

# make directory for back up files.
# when this operation fails, return error code and exit.
if [ ! -d $BACKUPDIR ]; then
    mkdir -p $BACKUPDIR
    if [ $? -ne 0 ]; then
        exit 1
    fi
fi

# back up logfiles of non-zero size.
for FILE in ${LOGFILES[@]}; do
    if [ -s $LOGDIR/$FILE ]; then
        mv $LOGDIR/$FILE $BACKUPDIR/$FILE.${DATE[2]}
        if [ $? -ne 0 ]; then
            RET=1
        fi
        touch $LOGDIR/$FILE
        # touch will never fail.
    fi
done

# restart the syslog daemon.
kill -HUP `cat /var/run/syslogd.pid`
if [ $? -ne 0 ]; then
    exit 1
fi

# change mode files' permisson that only users in root groups can read.
for FILE in ${LOGFILES[@]}; do
    if [ -f $LOGDIR/$FILE ]; then
        chmod 0640 $LOGDIR/$FILE
    fi
done

# compress back up files.
for FILE in ${LOGFILES[@]}; do
    if [ -f $BACKUPDIR/$FILE.${DATE[2]} ]; then
        bzip2 $BACKUPDIR/$FILE.${DATE[2]}
        if [ $? -ne 0 ]; then
            RET=1
        fi
    fi
done

exit $RET
