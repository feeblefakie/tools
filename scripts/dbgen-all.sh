#!/bin/sh

#pdsh -f 40 -g hitachi "~/svn/scripts/dbgen.sh 16000 40" | dshbak -c
#pdsh -g 20slaves "~/svn/scripts/dbgen.sh 12000 20" | dshbak -c
#pdsh -g tmpslaves -f 128 "~/svn/scripts/dbgen.sh 3200 100" | dshbak -c
#pdsh -g tmpslaves -f 128 "~/svn/scripts/dbgen.sh 6400 100" | dshbak -c
pdsh -g slaves -f 128 "~/svn/scripts/dbgen.sh 127000 127" | dshbak -c
#pdsh -g 16slaves-aoba -f 128 "~/svn/scripts/dbgen.sh 1600 16" | dshbak -c
#pdsh -g all -f 128 "~/svn/scripts/dbgen.sh 12800 128" | dshbak -c
#pdsh -g slaves -f 128 "~/svn/scripts/dbgen.sh 1000 127" | dshbak -c
#pdsh -f 40 -w midori010 "~/svn/scripts/dbgen.sh 5600 14" | dshbak -c
#pdsh -f 40 -g slaves "~/svn/scripts/dbgen.sh 1400 14" | dshbak -c
