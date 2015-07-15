#!/bin/sh

base="/data/backup"
#base="/data/hadoopx"
app="tpch"
#app="receipt"
#app="mrbench"
#app="replica"
#group="atasks"
#group="sf127000"
group="sf1600"
#group="1"
tables=`ls $base/$app/$group/[locps]*`
#tables=`ls $base/$app/$group/[ur]*`

for srctable in $tables
do
    table=`basename $srctable`
    table=`echo $table | sed -e "s/\.tbl\.*[0-9]*$//"`
    host=`basename \`hostname\` .tkl.iis.u-tokyo.ac.jp`
    #partno=`echo $host | sed -e "s/midori//g" | awk '{printf "%05d", $1-2}'`
    #partno=`echo $host | sed -e "s/midori//g" | awk '{printf "%05d", $1-1}'`
    partno=`echo $host | sed -e "s/aoba//g" | awk '{printf "%05d", $1-1}'`
    #partno=`echo $host | sed -e "s/clstr//g" | sed -e "s/p1//g" | awk '{printf "%05d", $1}'`
    echo "hadoop fs -put $srctable $app/$group/$table/part-$partno"
    hadoop fs -put $srctable $app/$group/$table/part-$partno
done
