#!/bin/sh

for i in `seq 1 40`
do
    id=`echo $i | awk '{printf "%02d", $1}'`
    pdsh -w clstr${id}p1 "~/svn/scripts/slave-mbps.sh" | dshbak -c 
done

