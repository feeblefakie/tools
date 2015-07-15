#!/bin/sh

threads="1 5 10 20 30 40 50 60 70 80 90 100"

for thread in $threads
do
    echo "$thread:"
    ./random sdd1 512 1 300 $thread
    ./random sdd1 512 1 300 $thread
    ./random sdd1 512 1 300 $thread
done
