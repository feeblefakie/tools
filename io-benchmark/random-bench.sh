#!/bin/sh

ranges="0.0000001 0.000001 0.00001 0.0001 0.001 0.01 0.1 1"

for range in $ranges
do
    sudo ~/svn/io-benchmark/random /dev/sdb  4096 $range 1000000 1400
done
