#!/bin/sh

for i in `seq 1 10`
do
    id=`echo $i | awk '{printf "%02d", $1}'`
    pdsh -w clstr${id}p1 "sudo ~/svn/scripts/hadoop-slaves-disk-tuning.sh" | dshbak -c 
    pdsh -w clstr${id}p1 "~/svn/scripts/slave-iops.sh" | dshbak -c 
done

