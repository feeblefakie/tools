#!/bin/sh

fractions="1 0.5 0.25 0.125 0.0625 0.03125"

for fraction in $fractions
do
./randomw sdf1 512 $fraction 300 
./randomw sdf1 512 $fraction 300 
./randomw sdf1 512 $fraction 300 
./randomw sdf1 4096 $fraction 300 
./randomw sdf1 4096 $fraction 300 
./randomw sdf1 4096 $fraction 300 
./randomw sdf1 32768 $fraction 200 
./randomw sdf1 32768 $fraction 200 
./randomw sdf1 32768 $fraction 200 
./randomw sdf1 2621440 $fraction 200 
./randomw sdf1 2621440 $fraction 200 
./randomw sdf1 2621440 $fraction 200 
./randomw sdf1 2097152 $fraction 100 
./randomw sdf1 2097152 $fraction 100 
./randomw sdf1 2097152 $fraction 100 
./randomw sdf1 16777216 $fraction 50
./randomw sdf1 16777216 $fraction 50
./randomw sdf1 16777216 $fraction 50
./randomw sdf1 134217728 $fraction 20
./randomw sdf1 134217728 $fraction 20
./randomw sdf1 134217728 $fraction 20
./randomw sdf1 268435456 $fraction 10
./randomw sdf1 268435456 $fraction 10
./randomw sdf1 268435456 $fraction 10
./randomw sdf1 536870912 $fraction 10
./randomw sdf1 536870912 $fraction 10
./randomw sdf1 536870912 $fraction 10
echo ""
done
