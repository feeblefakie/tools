#!/bin/sh

# 自動起動の設定
sudo /sbin/chkconfig ypbind on
sudo /sbin/chkconfig portmap on

# RPMForgeのレポジトリを追加
cd ~/rpm
sudo rpm -i rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm

# yum追加分
sudo yum -y install glibc
sudo yum -y install glibc-devel
sudo yum -y install libstdc++-devel
sudo yum -y install libaio-devel
sudo yum -y install sysstat
sudo yum -y install netperf
sudo yum -y install ruby
sudo yum -y install pdsh

# java
cd ~/rpm
sudo sh jdk-6u26-linux-x64-rpm.bin

# CDH (Hadoop) @ midori001
cd ~/rpm
sudo yum --nogpgcheck localinstall cdh3-repository-1.0-1.noarch.rpm
sudo rpm --import http://archive.cloudera.com/redhat/cdh/RPM-GPG-KEY-cloudera
sudo yum -y install hadoop-0.20
#sudo yum -y install hadoop-0.20-native
sudo yum -y install hadoop-0.20-namenode
sudo yum -y install hadoop-0.20-secondarynamenode
sudo yum -y install hadoop-0.20-jobtracker

# CDH (Hadoop) @ midori002 -
cd ~/rpm
sudo yum --nogpgcheck -y localinstall cdh3-repository-1.0-1.noarch.rpm
sudo rpm --import http://archive.cloudera.com/redhat/cdh/RPM-GPG-KEY-cloudera
sudo yum -y install hadoop-0.20
#sudo yum -y install hadoop-0.20-native
sudo yum -y install hadoop-0.20-datanode
sudo yum -y install hadoop-0.20-tasktracker

# BDB
cd ~/src/db-5.2.36/build_unix
sudo make install
sudo cp /usr/local/BerkeleyDB.5.2/lib/db.jar /usr/lib/hadoop/lib/
sudo ln -sf /usr/local/BerkeleyDB.5.2/lib/libdb*.so /usr/lib/

# Others
sudo mkdir /etc/hadooode
sudo ln -sf /home/hiroyuki/hadooode-conf /etc/hadooode/conf

# Smart
sudo cp ~/smartd.conf /etc/
sudo /etc/init.d/smartd restart

