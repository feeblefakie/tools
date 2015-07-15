#!/bin/sh

if [ $# -ne 2 ]; then
    echo "hdfs_download hdfs_dir local_dir"
    exit 1;
fi
hdfs_dir=$1
local_dir=$2

host=`basename \`hostname\` .tkl.iis.u-tokyo.ac.jp`
host=`echo $host | sed -e "s/midori//g" | awk '{printf "%05d", $1-2}'`
#host="00000"
name=`basename $hdfs_dir`
echo "hadoop fs -get $hdfs_dir/part-$host $local_dir/$name"
hadoop fs -get $hdfs_dir/part-$host $local_dir/$name
