#!/bin/sh

# IMPORTANT: You need to download the kernel source (2.6.18-308.16.1.el5) like the way explained in the following site.
# http://wiki.centos.org/HowTos/I_need_the_Kernel_Source

# This rebuild procedure is based on the one explained in the following site.
# http://wiki.centos.org/HowTos/BuildingKernelModules

kernel="2.6.18-308.16.1.el5"

# IMPORTANT: patch megaraid_sas.h with megaraid_sas.h.patch before proceeding.
#
# megaraid_sas.h is placed at 
# rpmbuild/BUILD/kernel-2.6.18/linux-2.6.18-308.16.1.el5.x86_64/drivers/scsi/megaraid/megaraid_sas.h

cd ~/rpmbuild/BUILD/kernel-2.6.18/linux-2.6.18-308.16.1.el5.x86_64/
make oldconfig
make menuconfig
make prepare
make modules_prepare
make M=drivers/scsi/megaraid
strip --strip-debug  drivers/scsi/megaraid/*.ko
sudo cp drivers/scsi/megaraid/*.ko /lib/modules/$kernel/extra
echo "executing depmod ..."
sudo /sbin/depmod -a
sudo cp  /boot/initrd-`uname -r`.img  /boot/initrd-`uname -r`-org.img
sudo cp  /boot/initrd-$kernel.img  /boot/initrd-$kernel-org.img
echo "executing mkinitrd ..."
sudo /sbin/mkinitrd -f /boot/initrd-$kernel.img $kernel

# Restart the operating system 

# Check if the queue depth is changed (the queue depth must be 1008)
# cat /sys/block/xxx/device/queue_depth
