#!/bin/sh -x

result=result.out
iosize=512
threads="1 5 10 20 30 40 50 60 70 80 90 100 200 300"

for thread in $threads
do
    sync;sync;sync;echo 3 > /proc/sys/vm/drop_caches; sync;sync;sync;
    ./random md0 $iosize 0.1 1 1
    echo -n "numRequests: 10000 numThreads: $thread " >> $result
    ./random md0 $iosize 0.1 10000 $thread >> $result
done
