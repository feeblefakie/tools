#!/bin/sh

grep "DISPATCH" $1 | awk '{print $5 " " $7 " " $9}'
