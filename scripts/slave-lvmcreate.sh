#!/bin/sh

#sudo /usr/sbin/vgremove VolGroup01
#sudo /usr/sbin/vgreduce --removemissing VolGroup01
#sudo /usr/sbin/pvremove /dev/sdb

sudo /usr/sbin/pvcreate /dev/sdb
sudo /usr/sbin/vgcreate VolGroup01 /dev/sdb
sudo /usr/sbin/lvcreate -L 3T -n LVHadooodeExp VolGroup01
sudo /usr/sbin/lvcreate -L 7T -n LVHadoop VolGroup01
#sudo /usr/sbin/lvcreate -L 5T -n LVHadoopX VolGroup01
sudo /usr/sbin/lvcreate -L 7.9T -n LVBackup VolGroup01
