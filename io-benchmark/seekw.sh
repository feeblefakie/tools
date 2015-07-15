#!/bin/sh

SECTOR_OFFSET=286744100
#SECTOR_INT=2097152
SECTOR_INT=204800

# assume that first 190 MB is used for FS metadata
while [ $SECTOR_OFFSET -ge 389120 ]
do
    ./seekw sdf1 $SECTOR_OFFSET
    SECTOR_OFFSET=`expr $SECTOR_OFFSET - $SECTOR_INT`
done
