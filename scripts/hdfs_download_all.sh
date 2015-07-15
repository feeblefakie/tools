#!/bin/sh -x

#files="lineitem lineitem.l_orderkey.gindex lineitem.l_partkey.gindex lineitem.l_shipdate.index lineitem.l_suppkey.gindex orders orders.o_custkey.gindex orders.o_orderdate.index orders.o_orderkey.gindex orders.o_totalprice.index part part.p_brand.index part.p_partkey.gindex part.p_retailprice.index partsupp partsupp.ps_suppkey.gindex supplier supplier.s_nationkey.gindex supplier.s_suppkey.gindex supplier.s_suppkey.index customer customer.c_acctbal.index customer.c_custkey.gindex customer.c_mktsegment.index customer.c_nationkey.gindex nation nation.n_name.index nation.n_nationkey.gindex nation.n_regionkey.gindex region region.r_name.index region.r_regionkey.gindex"
#files="lineitem lineitem.l_orderkey.gindex orders orders.o_custkey.gindex customer customer.c_acctbal.index"
# lineitem.l_receiptdate.index
files="lineitem lineitem.l_orderkey.gindex lineitem.l_partkey.gindex lineitem.l_shipdate.index orders orders.o_custkey.gindex orders.o_orderdate.index orders.o_orderkey.gindex orders.o_totalprice.index customer customer.c_custkey.gindex customer.c_mktsegment.index customer.c_nationkey.gindex nation nation.n_name.index nation.n_nationkey.gindex nation.n_regionkey.gindex part part.p_retailprice.index part.p_type.index region region.r_name.index region.r_regionkey.gindex supplier supplier.s_nationkey.gindex supplier.s_suppkey.gindex supplier.s_suppkey.index"

hdfs_dir="/user/hiroyuki/replica/sf20000"
#hdfs_dir="/user/hiroyuki/tpch/sf5600"
local_dir="/data/hadooode/sf20000"
#local_dir="/data"

pdsh -g slaves "mkdir -p $local_dir" | dshbak -c
for file in $files
do
    pdsh -g slaves "/home/hiroyuki/svn/scripts/hdfs_download.sh $hdfs_dir/$file $local_dir" | dshbak -c
    #pdsh -w midori020 "/home/hiroyuki/svn/scripts/hdfs_download.sh $hdfs_dir/$file $local_dir" | dshbak -c
done
