#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Initial Date: 2016-09-04
#------------------------------------------------------------------------------

error() { echo "--error-- $@" 1>&2; exit -1; }

if [ $# -ne 1 ]
then
    error "usage: $(basename $0) <filelist>"    
fi

filelist=$1

DESTDIR=/share/USBDisk1/nas
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H-%M-%S)
BACKUPDIR=$DESTDIR/_backup-logs/$DATE.$TIME


cd $DESTDIR

if [ "$(pwd)" != "$DESTDIR" ]
then
    error "Must be run from $DESTDIR"
fi

mkdir -p $BACKUPDIR
failfile=$BACKUPDIR/FAILED

dirs=( $(cat $filelist) )

for (( i=0; i<${#dirs[@]}; i+=2 ))
do
    src=${dirs[$i]}
    dest=${dirs[$i+1]}
    log=$BACKUPDIR/$(basename $dest).log

    rsync --recursive           \
            --links             \
            --stats             \
            --times             \
            --omit-dir-times    \
            --itemize-changes   \
            --progress          \
            --human-readable    \
            --delete-before     \
            $src $dest 2>&1 | tee $log

    if [ ${PIPESTATUS[0]} -ne 0 ]
    then
        msg="backup failed: $src $dest"
        echo $dest >> $failfile
    else
        msg="$dest [ok]"
    fi

    echo $msg | tee -a $log

done

