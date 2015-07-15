#!/bin/sh

data=/data/hadooode/sf2400
fromhost=`basename \`hostname\` .tkl.iis.u-tokyo.ac.jp`
tohost=`echo $fromhost | sed -e "s/midori//g" | awk '{printf "midori%03d", ($1+5)%15+1}'`
scp -r $data $tohost:$data.$fromhost.bak
