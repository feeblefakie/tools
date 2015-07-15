#!/bin/sh

script_home=/home/hiroyuki
#sudo yum --nogpgcheck localinstall $script_home/rpm/cdh3-repository-1.0-1.noarch.rpm
sh $script_home/rpm/jdk-6u26-linux-x64-rpm.bin

#packages="zsh vim-common vim-enhanced hadoop-0.20 hadoop-0.20-namenode hadoop-0.20-datanode hadoop-0.20-secondarynamenode hadoop-0.20-jobtracker hadoop-0.20-tasktracker hadoop-0.20-conf-pseudo emacs"
packages=`cat packages.list`

for package in $packages
do
    echo $package
    yum -y install $package
done
