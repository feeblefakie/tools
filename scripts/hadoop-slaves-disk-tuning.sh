#!/bin/sh

USER=`whoami`
if [ $USER != root ]; then
    echo "Must be root to run this script."
    exit
fi

files=`ls -d /sys/block/sd*`
for file in $files
do
    echo $file
    echo "noop" > "$file/queue/scheduler"
    cat "$file/queue/scheduler"
    echo 1008 > "$file/queue/nr_requests"
    #echo 30 > "$file/queue/nr_requests"
    cat "$file/queue/nr_requests"
    #echo 512 > "$file/device/queue_depth"
    cat "$file/device/queue_depth"
done
