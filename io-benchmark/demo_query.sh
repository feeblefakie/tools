#!/bin/sh

if [ $# != 1 ]; then
    echo "$0 ooo/io"
    exit
fi

if [ $1 == "ooo" ]; then
    # out-of-order
    pdsh -g all -f 128 "sudo ~/svn/io-benchmark/random /dev/sdb 4096 1 15000 1400" | dshbak -c
else
    # in-order
    pdsh -g all -f 128 "sudo ~/svn/io-benchmark/random /dev/sdb 4096 1 1500 1" | dshbak -c
fi 
#pdsh -g all -f 128 "sudo ~/svn/io-benchmark/random /dev/sdb 4096 1 400000 1400" | dshbak -c

