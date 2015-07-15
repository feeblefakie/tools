#!/usr/bin/env perl

use strict;
use warnings;
use constant SAMPLES => 100;
use constant FS_USED => 1024*1024*190/512;

my @seps = (16384000, 46899200, 78233600, 109158400, 138444800, 161792000, 184524800, 202547200, 220364800, 236544000, 264192000, 275865600, 286515200);
#my @access_lengths = (4096, 10240, 102400, 1048576, 10485760, 104857600); # 1K, 10K, 100K, 1M, 10M, 100M
my @access_lengths = (102400, 1048576, 10485760, 104857600); # 1K, 10K, 100K, 1M, 10M, 100M

my $prev_sep = 0;
foreach my $sep (@seps) {
    print "BEFORE $sep\n";
    foreach my $access_length (@access_lengths) {
        my $transfer_total = 0;
        foreach (1 .. SAMPLES) {
            my $sector;
            while (1) {
                $sector = int(rand($sep-$prev_sep));
                last if $sector >= FS_USED;
            }
            $sector += $prev_sep;
            my $result = `./latencyw sdf1 $sector $access_length`;
            my $latency = (split / /, $result)[8];
            chop($latency);
            $result = `./seekw sdf1 $sector`;
            my $seek = (split / /, $result)[6];
            chop($seek);
            my $transfer_sample = $latency - $seek;
            #my $mbs_sample = $access_length / $transfer_sample / (1024*1024);
            $transfer_total += $transfer_sample;
            #print "[info] sectors: $sector access_length(bytes): $access_length average_transfer_time(s): $transfer_sample MB/s: $mbs_sample\n";
        }
        my $transfer = $transfer_total / SAMPLES;
        my $mbs = $access_length / $transfer / (1024*1024);
        print "access_length(bytes): $access_length average_transfer_time(s): $transfer MB/s: $mbs\n";
    }
    $prev_sep = $sep;
}



