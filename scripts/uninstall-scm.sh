#!/bin/sh

yum -y remove cloudera-scm-agent 
yum -y remove hadoop-0.20 hadoop-0.20-native hadoop-0.20-sbin hadoop-zookeeper hadoop-hive hadoop-hbase hue*
yum -y remove cloudera-scm-free cloudera-cdh
