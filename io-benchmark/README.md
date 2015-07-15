# I/O Benchmarking Tools

Build all programs.
$ Make

Read IOPS (device: /dev/sdb, blocksize: 4096, range: 1(all), # of ios: 200000, io parallelism: 1400)
$ sudo ./random /dev/sdb 4096 1 200000 1400
