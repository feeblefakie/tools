#!/bin/sh

if [ $# -ne 1 ]; then
    echo "$0 col_offset"
    exit 1
fi

off=$1
 
#awk -F ',' '{print $'$off'}' - | sort -n -S 64M | uniq -c | awk '{print $1}'
awk -F ',' '{print $'$off'}' - | sort -n -S 64M | uniq -c | awk '{print $1}' | sort -n -S 64M | uniq -c
