#!/bin/sh

#host=`hostname | sed -e "s/aoba//g" | awk '{printf "%02d", $1-2}'`
#host=`hostname | sed -e "s/clstr//g" | sed -e "s/p1//g"` 
sudo /home/hiroyuki/svn/io-benchmark/sequential mapper/VolGroup01-LogVol00
