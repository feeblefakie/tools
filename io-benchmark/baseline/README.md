# I/O Benchmarking by FIO

###Preparation
* Install FIO
```
$ sudo yum install fio
```
* Figure out device file or filesystem's file to measure
* Adjust the scheduler
```
$ cat /sys/block/[DEVICE]/queue/scheduler
```

* set noop or cfq or deadline
```
$ echo "noop" > /sys/block/[DEVICE]/queue/scheduler
```

###Mesure read IOPS 
* edit filename and iodepth in fio-randomio as needed
```
$ sudo fio fio-randomio
```

###Mesure write IOPS 
* edit filename and iodepth in fio-randomiow as needed
```
$ sudo fio fio-randomiow
```

###Mesure seaquential read throuput (MB/s)
* edit filename in fio-seqio as needed

```
$ sudo fio fio-seqio
```

###Mesure seaquential write throuput (MB/s)
* edit filename in fio-seqiow as needed
```
$ sudo fio fio-seqiow
```
