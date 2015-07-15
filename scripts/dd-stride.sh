#!/bin/sh

#for i in `seq 1 10`; do sudo dd if=/dev/sdb of=/dev/zero bs=64K count=49152 skip=$[$i*49152] iflag=direct & done
for i in `seq 1 10`; do sudo dd if=/dev/sdb of=/dev/zero bs=1M count=3072 skip=$[$i*3072] iflag=direct & done
