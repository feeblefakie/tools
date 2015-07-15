#!/bin/sh

threads="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120"

for thread in $threads
do
    echo "$thread: "
    #./interface sdc1 1 $thread
    #./interface sdc1 2 $thread
    #./interface sdc1 4 $thread
    #./interface sdc1 8 $thread
    #./interface sdc1 16 $thread
    #./interface sdc1 32 $thread
    #./interface sdc1 64 $thread
    #./interface sdc1 128 $thread
    #./interface sdc1 256 $thread
    #./interface sdc1 512 $thread
    #./interface sdc1 1024 $thread
    ./interface sdc1 1536 $thread
    #./interface sdc1 2048 $thread
    #./interface sdc1 4096 $thread
    #./interface sdc1 8192 $thread
    #./interface sdc1 16384 $thread
    #./interface sdc1 32768 $thread
    #./interface sdc1 65536 $thread
    #./interface sdc1 131072 $thread
    #./interface sdc1 262144 $thread
done
