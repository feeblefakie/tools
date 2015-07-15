#!/bin/sh

sudo mount -t ext4 /dev/mapper/VolGroup01-LVHadooodeExp /data/exp
sudo mount -t ext3 /dev/mapper/VolGroup01-LVHadooodeDemo /data/demo                     
sudo mount -t ext3 /dev/mapper/VolGroup01-LVHadoopX /data/hadoopx                     
sudo mount -t ext3 /dev/mapper/VolGroup01-LVBackup /data/backup                              
sudo mount -t ext3 /dev/mapper/VolGroup01-LVHadoop /data/hadoop                   
