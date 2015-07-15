#!/bin/sh

threads="1 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30"

for thread in $threads
do
    #./interface-para 1 6 $thread
    #./interface-para 2 6 $thread
    #./interface-para 4 6 $thread
    #./interface-para 8 6 $thread
    #./interface-para 16 6 $thread
    #./interface-para 32 6 $thread
    #./interface-para 64 6 $thread
    #./interface-para 128 6 $thread
    #./interface-para 256 6 $thread
    #./interface-para 512 6 $thread
    #./interface-para 1024 6 $thread
    ./interface-para 2048 6 $thread
done
