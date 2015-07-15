#!/bin/sh

file="part"
hdfs_dir="/user/hiroyuki/replica/sf5600/$file.224"
local_dir="/data/hadooode/perf"
fileids=`seq 0 15 | xargs`

pdsh -g slaves "mkdir -p $local_dir" | dshbak -c
for fileid in $fileids
do
    for i in `seq 0 13`
    do
        tmpid=`expr $fileid '*' 14 + $i`
        part=`echo $tmpid | awk '{printf "%05d", $1}'`
        hostid=`echo $i | awk '{printf "midori%03d", $1+2}'`
        echo "pdsh -w $hostid \"hadoop fs -get $hdfs_dir/part-$part $local_dir/$file.$fileid\" | dshbak -c"
        pdsh -w $hostid "hadoop fs -get $hdfs_dir/part-$part $local_dir/$file.$fileid" | dshbak -c &
    done
    wait
done
