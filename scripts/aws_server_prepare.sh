#!/bin/sh

if [ $# -ne 1 ]; then
    echo "$0 master/slave"
    exit 1
fi
role=$1

package=hadooode-package-20140313.tgz

# yum installs
rpm -ihv ~/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm 
yum -y install zsh
yum -y install pdsh
yum -y install e4fsprogs
yum -y install libaio-devel
yum -y install perl-XML-Simple

# Configure pdsh
mkdir -p ~/.dsh/group
echo -e "aws002\naws003\naws004\naws005\naws006\naws007\naws008\naws009\naws010\naws011\naws012\naws013\naws014\naws015\naws016\naws017" > ~/.dsh/group/slaves
echo -e "aws001\naws002\naws003\naws004\naws005\naws006\naws007\naws008\naws009\naws010\naws011\naws012\naws013\naws014\naws015\naws016\naws017" > ~/.dsh/group/all

# LVM setup
pvcreate /dev/sd[b-y]
vgcreate VolGroup01 /dev/sd[b-y]
lvcreate -i 24 -I 64 -L 3T -n LVHadooodeExp VolGroup01
lvcreate -i 24 -I 64 -L 7T -n LVHadoop VolGroup01
lvcreate -i 24 -I 64 -L 3T -n LVBackup VolGroup01

# FS setup
mkfs -t ext4 /dev/mapper/VolGroup01-LVHadooodeExp
mkfs -t ext3 /dev/mapper/VolGroup01-LVHadoop
mkfs -t ext4 /dev/mapper/VolGroup01-LVBackup

# directories setup
mkdir -p /data/exp
mkdir -p /data/hadoop
mkdir -p /data/backup
mount -t ext4 /dev/mapper/VolGroup01-LVHadooodeExp /data/exp
mount -t ext3 /dev/mapper/VolGroup01-LVHadoop /data/hadoop
mount -t ext4 /dev/mapper/VolGroup01-LVBackup /data/backup
chmod 777 /data/exp
chmod 777 /data/hadoop
chmod 777 /data/backup

# TODO: this is enough ?
files=`ls -d /sys/block/sd*`
for file in $files
do
    echo "noop" > "$file/queue/scheduler"
    echo 1400 > "$file/queue/nr_requests"
done

cd ~/
tar zxvf ~/$package
cd ~/hadooode
tar zxvf hadooode-dist.tgz

# Install Hadoop and Hadooode
cp ./hadooode-dist/scripts/setup_hadoop.sh .
cp ./hadooode-dist/scripts/setup_hadooode.sh .
./setup_hadoop.sh $role ~/cloudera-cdh-4-0.x86_64.rpm
./setup_hadooode.sh $role /usr/lib/hadoop-0.20-mapreduce

# Configure Hadoop
rm -rf /etc/hadoop/conf/*
cp -r ~/aws-hadoop-conf/* /etc/hadoop/conf/

# Configure Hadooode
mkdir -p /etc/hadooode/conf
rm -rf /etc/hadooode/conf/*
cp -r ~/aws-hadooode-conf/* /etc/hadooode/conf/

# start Hadoop
./hadooode-dist/scripts/start_hadoop $role
