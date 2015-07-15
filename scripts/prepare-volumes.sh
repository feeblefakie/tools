#!/bin/sh

nodeids="010 011 012 013 014 015"

for nodeid in $nodeids 
do
    #pdsh -w midori$nodeid "sudo /usr/sbin/pvcreate /dev/sd[b-i]" | dshbak -c
    #pdsh -w midori$nodeid "sudo /usr/sbin/vgcreate VolGroup01 /dev/sd[b-i]" | dshbak -c
    #pdsh -w midori$nodeid "sudo /usr/sbin/lvcreate -i 8 -I 64 -L 10T -n LogVol00 VolGroup01" | dshbak -c
    #pdsh -w midori$nodeid "sudo /usr/sbin/lvcreate -i 8 -I 64 -L 3160G -n LogVol01 VolGroup01 " | dshbak -c
    #pdsh -w midori$nodeid "sudo /sbin/mkfs -t ext3 /dev/VolGroup01/LogVol00" | dshbak -c
    
    pdsh -w midori$nodeid "sudo mkdir /data" | dshbak -c
    pdsh -w midori$nodeid "sudo chmod -R 777 /data" | dshbak -c
    pdsh -w midori$nodeid "sudo mount -t ext3 /dev/VolGroup01/LogVol00 /data" | dshbak -c
done

