#!/bin/sh

#wget http://archive.cloudera.com/redhat/cdh/cdh3-repository-1.0-1.noarch.rpm
sudo yum -y --nogpgcheck localinstall ~/rpm/cdh3-repository-1.0-1.noarch.rpm
sudo rpm --import http://archive.cloudera.com/redhat/cdh/RPM-GPG-KEY-cloudera
sudo yum -y install hadoop-0.20 hadoop-0.20-datanode hadoop-0.20-tasktracker
