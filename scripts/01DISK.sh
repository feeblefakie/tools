#!/bin/sh
# original file : /home/kgoda/20110415.iotest.16xAMS2500/03DISK.sh

USER=`whoami`
if [ $USER != root ]; then
    echo "Must be root to run this script."
    exit
fi

cd `dirname $0`
tmp_devices=/tmp/devices.`date +%Y%m%d`

f1=$tmp_devices.1.$$
f2=$tmp_devices.2.$$

#

/sbin/multipath -l | \
    #grep -v '\[' | \ 
    grep 'HITACHI' | \
    awk '{print $1,$2}' > $f1

for d in `cat $f1 | awk '{print $1}'`
do
    echo $d
    /sbin/multipath -l $d | \
	grep ' \\_' | \
	grep 'active' | \
	awk 'BEGIN{FS="[: ]"} {printf "%03d %03d:%03d:%03d:%03d ", $6,$3,$4,$5,$6 }' >> $f2
    echo -n $d >> $f2
    echo -n " "  >> $f2
    grep $d $f1 | awk '{print $2}' >> $f2
done

sort $f2 > $tmp_devices
rm $f1 $f2

cat $tmp_devices

#

for d in `cat $tmp_devices | awk '{print $4}'`
do
    sleep 1
    echo $d
    #chown hitachi:wheel /dev/$d
    echo -n '  '
    ls -la /dev/$d
    for d2 in `find /sys/block/$d/slaves/*/queue/scheduler`
    do
      echo -n '  '
      echo -n $d2
      echo noop > $d2
      #echo cfq > $d2
      echo -n ": "
      cat $d2
    done
    for d2 in `find /sys/block/$d/slaves/*/queue/nr_requests`
    do
      echo -n '  '
      echo -n $d2
      #echo 8192 > $d2
      #echo 128 > $d2
      echo 256 > $d2
      echo -n ": "
      cat $d2
    done
    for d2 in `find /sys/block/$d/slaves/*/device/queue_depth`
    do
      echo -n '  '
      echo -n $d2
      #echo 256 > $d2
      echo -n ": "
      cat $d2
    done
    # Wipe out the boot sector of each device
    # This is necessary something like a bug of dm-multipath
    # dd if=/dev/zero of=/dev/$d bs=512 count=1 > /dev/null 2>&1
done

echo -n '  '
echo -n /proc/sys/fs/aio-max-nr
echo 262144 > /proc/sys/fs/aio-max-nr    
#echo 65536 > /proc/sys/fs/aio-max-nr    
echo -n ": "
cat /proc/sys/fs/aio-max-nr
<<'#__COMMENT_OUT__'
#__COMMENT_OUT__

#/sbin/mdadm --create /dev/md0 -v -v --force -e 1.0 \
#    --level=raid0 --chunk=64 --raid-devices=`wc -l $tmp_devices | awk '{print $1}'` \
#    `awk '{printf "/dev/mpath/%s ",$3}' $tmp_devices | tr "\n" " "`
#chown kgoda:wheel /dev/md0
#
#cat /proc/mdstat

# end
