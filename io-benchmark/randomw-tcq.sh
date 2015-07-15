#!/bin/sh

threads="1 5 10 20 30 40 50 60 70 80 90 100 110 120"

for thread in $threads
do
    echo "$thread:"
    ./randomw sdb1 512 1 300 $thread
    ./randomw sdb1 512 1 300 $thread
    ./randomw sdb1 512 1 300 $thread
done
