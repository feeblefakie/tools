#!/bin/sh

host=`basename \`hostname\` .tkl.iis.u-tokyo.ac.jp`
date=`date '+%Y%m%d'`
resfile=$host.iops.$date.long3

cd $HOME/svn/io-benchmark
rm -f $resfile

for i in 1 2 3 4 5 6 7 8 9 10
do
    sudo ./random mapper/VolGroup01-LogVol00 512 1 300000 1000 >> $resfile
done
echo -n "Average: " >> $resfile
awk '{a+=$3; print a/10}' $resfile | tail -1 >> $resfile
