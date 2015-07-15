#!/bin/sh

jobids=`mapred job -list | grep "^job_" | awk '{print $1}'`
for jobid in $jobids
do
    mapred job -kill $jobid
done
