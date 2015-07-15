#!/bin/sh

#clstrids="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40"
clstrids="01 02 03 04 05 06 07 08 09 10"
#clstrids="03"

cd ~/hitachi

for clstrid in $clstrids
do
    #lus=`head -8 $clstrid | tr '\n' ' '`
    lus=`cat $clstrid | tr '\n' ' '`
    pdsh -w clstr${clstrid}p1 "sudo /sbin/pvcreate $lus" | dshbak -c
    pdsh -w clstr${clstrid}p1 "sudo /sbin/vgcreate VolGroupHadoop$clstrid $lus" | dshbak -c
    pdsh -w clstr${clstrid}p1 "sudo /sbin/lvcreate -i 12 -I 64 -L 3000G -n LogVol01 VolGroupHadoop$clstrid" | dshbak -c
    pdsh -w clstr${clstrid}p1 "sudo /sbin/lvcreate -i 12 -I 64 -L 3000G -n LogVol02 VolGroupHadoop$clstrid" | dshbak -c
    #pdsh -w clstr${clstrid}p1 "sudo /sbin/mkfs -t ext3 /dev/mapper/VolGroupHadoop$clstrid-LogVol01" | dshbak -c
    #pdsh -w clstr${clstrid}p1 "sudo mkdir /data" | dshbak -c
    #pdsh -w clstr${clstrid}p1 "sudo mount -t ext3 /dev/mapper/VolGroupHadoop$clstrid-LogVol01 /data" | dshbak -c
    #pdsh -w clstr${clstrid}p1 "sudo chmod -R 777 /data" | dshbak -c
done
