#!/bin/sh

if [ $# -ne 2 ]; then
    echo "$0 sf num_nodes"
    exit 1;
fi

sf=$1
num_nodes=$2

host=`hostname`
#id=`echo $host | sed -e s/clstr//g | sed -e s/p1//g | awk '{printf "%1d", $1}'`
id=`echo $host | sed -e s/midori//g | awk '{printf "%1d", $1-1}'`
#id=`echo $host | sed -e s/aoba//g | awk '{printf "%1d", $1-1}'`
#id=`echo $host | sed -e s/midori//g | awk '{printf "%1d", $1}'`

cd ~/src/tpch/dbgen/sf$sf
echo "~/src/tpch/dbgen/dbgen -f -s $sf -C $num_nodes -S $id"
~/src/tpch/dbgen/dbgen -f -s $sf -C $num_nodes -S $id
