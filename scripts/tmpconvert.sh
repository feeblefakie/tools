#!/bin/sh

host=`basename \`hostname\` .tkl.iis.u-tokyo.ac.jp`
# 00-20
partno=`echo $host | sed -e "s/midori//g" | awk '{printf "%02d", $1-2}'`

cd /data/backup/mrbench/atasks/
#awk -F '|' '{print $1 "|" '$partno' "-" $2 "|" $3}' Rankings.dat > Rankings
awk -F '|' '{print $1 "|" '$partno' "-" $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" $7 "|" $8 "|" $9}' UserVisits.dat > uservisits
