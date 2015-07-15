#!/bin/sh

fractions="1 0.5 0.25 0.125 0.0625 0.03125"

for fraction in $fractions
do
    echo $fraction
    ./randomw sdf1 512 $fraction 300 
    ./randomw sdf1 512 $fraction 300 
    ./randomw sdf1 512 $fraction 300 
    ./randomw sdf1 512 $fraction 300 
    ./randomw sdf1 512 $fraction 300 
done
