#!/bin/sh

cd /opt/mapr/hadoop/hadoop-0.20.2/
for i in `seq 10`; do (bin/hadoop jar lib/maprfs-test-0.1.jar com.mapr.fs.RWSpeedTest /perf2/z${i} -10000 maprfs:///) & done
