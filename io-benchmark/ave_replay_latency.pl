#!/usr/bin/env perl

use strict;
use warnings;

my @sep = (16384000, 46899200, 78233600, 109158400, 138444800, 161792000, 184524800, 202547200, 220364800, 236544000, 264192000, 275865600, 286515200);

MAIN:
{
    my $latency = {};
    while (<>) {
        chomp;
        my @items = split / /;
        foreach (@sep) {
            if ($items[1] <= $_) {
                $latency->{$_}->{sum} += $items[3];
                $latency->{$_}->{cnt}++;
                last;
            }
        }
    }

    foreach (@sep) {
        my $ave_latency = $latency->{$_}->{sum} / $latency->{$_}->{cnt};
        print "sectors: $_ ave_latency: $ave_latency\n";
    }
}

1;
