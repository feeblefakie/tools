#!/bin/sh

USER=`whoami`
if [ $USER != root ]; then
    echo "Must be root to run this script."
    exit
fi
sync;sync;sync;echo 3 > /proc/sys/vm/drop_caches; sync;sync;sync;
