#!/bin/sh

host=`hostname | sed -e "s/aoba//g" | awk '{printf "%02d", $1-2}'`
sudo /sbin/mkfs -t ext3 /dev/MyVolume$host/LogVol01
