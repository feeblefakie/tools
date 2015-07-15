#!/bin/sh

#host=`hostname | sed -e "s/aoba//g" | awk '{printf "%02d", $1-2}'`
#host=`hostname | sed -e "s/clstr//g" | sed -e "s/p1//g"` 
host=`hostname | sed -e "s/midori//g" | awk '{printf "%02d", $1-2}'`
#sudo /home/hiroyuki/svn/io-benchmark/random /dev/sdb 4096 1 100000 1400
#sudo fio /home/hiroyuki/svn/io-benchmark/fio-randomio-0:1TB
sudo fio /home/hiroyuki/svn/io-benchmark/fio-randomio
#sudo /home/hiroyuki/svn/io-benchmark/random_aio mapper/VolGroup01-LogVol00 512 1 200000 1
