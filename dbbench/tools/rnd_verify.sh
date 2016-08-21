#!/bin/sh 

progs="c_rnd c_mtrnd"

for prog in $progs
do
    ./$prog 100000 10000 | sort -n | uniq -c | awk '{print $1}' | sort -n | uniq -c > $prog.out  
done

progs="go_rnd go_mtrnd"

for prog in $progs
do
    ./$prog -num 100000 -max 10000 | sort -n | uniq -c | awk '{print $1}' | sort -n | uniq -c > $prog.out  
done
