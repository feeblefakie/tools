#!/bin/sh

host=`hostname`
# assumes aws002, ..., aws017
id=`echo $host | sed -e s/aws//g | awk '{printf "%1d", $1-1}'`

#cd ~/hadooode/tpch/dbgen
#make
cd ~/hadooode/tpch/dbgen/sf16000
~/hadooode/tpch/dbgen/dbgen -f -s 16000 -C 16 -S $id
# for test
#~/hadooode/tpch/dbgen/dbgen -f -s 1 -C 1 -S 1

hadoop fs -mkdir tpch/lineitem
hadoop fs -mkdir tpch/orders
hadoop fs -mkdir tpch/customer
hadoop fs -mkdir tpch/part
hadoop fs -mkdir tpch/partsupp
hadoop fs -mkdir tpch/supplier
hadoop fs -mkdir tpch/region
hadoop fs -mkdir tpch/nation

# upload to hdfs
hadoop fs -put lineitem* tpch/lineitem/
hadoop fs -put orders* tpch/orders/
hadoop fs -put customer* tpch/customer/
hadoop fs -put part* tpch/part/
hadoop fs -put partsupp* tpch/partsupp/
hadoop fs -put supplier* tpch/supplier/
hadoop fs -put region* tpch/region/
hadoop fs -put nation* tpch/nation/
