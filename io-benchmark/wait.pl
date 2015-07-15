#!/usr/bin/env perl

# [DISPATCHING]postmark(8057) 1 0xffff81007eee9068 start-sector: 128974919 size: 4096 1294831028423573779 FROM_DEVICE
# [DONE]swapper(0) 1 0xffff81007eee9068 start-sector: 128974919 1294831028431704776 FROM_DEVICE
# [DISPATCHING]postmark(8057) 1 0xffff81007eee9068 start-sector: 128974911 size: 4096 1294831028431844221 FROM_DEVICE

MAIN:
{
    my $n = 0;
    my $last_done = {};
    while (<>) {
        chomp;
        my $line = $_;
        ++$n;
        next if $n == 1;
        if ($line =~ /^\[DONE\]/) {
            my @items = split / /;
            $last_done->{sector} = $items[4];
            $last_done->{ts} = $items[5];
        } else {
            my @items = split / /;
            my @items = split / /;
            if ($items[4] == $last_done->{sector}) {
                print "[error] wrong format\n";
            } else {
                my $wait_time = $items[7] - $last_done->{ts};
                print "$wait_time\n";
            }
        }
    }
}

1;
