#!/bin/sh

#threads="1 5 10 20 30 40 50 60 70 80 90 100 110 120"
threads="80 90 100 110 120"

for thread in $threads
do
    echo "$thread: "
    ./interface sdd1 256 $thread
    ./interface sdd1 256 $thread
    ./interface sdd1 256 $thread
    #./interface sdb1 300 $thread
    #./interface sdb1 300 $thread
done
