#!/bin/sh

clstrids_01="01 02 03 04 05 06 07 08 09 10"
clstrids_02="11 12 13 14 15 16 17 18 19 20"
clstrids_03="21 22 23 24 25 26 27 28 29 30"
clstrids_04="31 32 33 34 35 36 37 38 39 40"
#clstrids="01"

cd ~/hitachi

for clstrid in $clstrids_01
do
    lus=`head -8 $clstrid | tr '\n' ' '`
    pdsh -w clstr01p1 "sudo /sbin/pvremove $lus" | dshbak -c
done

for clstrid in $clstrids_02
do
    lus=`head -8 $clstrid | tr '\n' ' '`
    pdsh -w clstr11p1 "sudo /sbin/pvremove $lus" | dshbak -c
done

for clstrid in $clstrids_03
do
    lus=`head -8 $clstrid | tr '\n' ' '`
    pdsh -w clstr21p1 "sudo /sbin/pvremove $lus" | dshbak -c
done

for clstrid in $clstrids_04
do
    lus=`head -8 $clstrid | tr '\n' ' '`
    pdsh -w clstr31p1 "sudo /sbin/pvremove $lus" | dshbak -c
done
