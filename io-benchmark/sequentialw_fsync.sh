#!/bin/sh

for i in `seq 1 20`
do
    time ./sequentialw_fsync /data/file.$i 10000000 > /data/file.latency.$i
    gnuplot -e "set terminal png; set output 'fsync-$i.png'; set xlabel 'time (sec)'; set ylabel 'latency (sec)'; plot '/data/file.latency.$i' u 1:2 w p t 'nvm fsync $i'"
    rm -f /data/file.$i
done 
