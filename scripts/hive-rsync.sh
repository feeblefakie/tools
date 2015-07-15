#!/bin/sh -x

rsync -v -r --exclude ".svn" --delete /home/hiroyuki/svn/hive-release-0.7.0/ql/src/java/org/apache/hadoop/hive/ql/ /home/hiroyuki/svn/hive/hive-release-0.7.0/ql/src/java/org/apache/hadoop/hive/ql
