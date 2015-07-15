#!/bin/sh

list=$1

while read i1 i2 i3
do
    echo ${i1} ${i2} ${i3}
    if [ "$i3" = "FROM_DEVICE" ]; then
        # read
        #./latency sdf1 ${i1} ${i2}
        ./sim ${i1} ${i2}
    else 
        # write
        #./latencyw sdf1 ${i1} ${i2}
        ./sim ${i1} ${i2} 1
    fi
done < ${list}
