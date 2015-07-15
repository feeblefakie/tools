#!/bin/sh

wget http://archive.cloudera.com/redhat/cdh/cdh3-repository-1.0-1.noarch.rpm
yum -y --nogpgcheck localinstall cdh3-repository-1.0-1.noarch.rpm
rpm --import http://archive.cloudera.com/redhat/cdh/RPM-GPG-KEY-cloudera
yum -y install hadoop-0.20 hadoop-0.20-namenode hadoop-0.20-secondarynamenode hadoop-0.20-jobtracker hadoop-hive
