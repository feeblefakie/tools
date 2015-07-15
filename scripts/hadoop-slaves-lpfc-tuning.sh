#!/bin/sh

USER=`whoami`
if [ $USER != root ]; then
    echo "Must be root to run this script."
    exit
fi

/sbin/modprobe -r lpfc
/sbin/modprobe lpfc lpfc_lun_queue_depth=128
