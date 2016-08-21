#!/bin/sh

gnuplot << EOF
set xlabel "frequency"
set ylabel "# of generated numbers"
set terminal pngcairo
set output "rnd_verify.png"
plot "./c_rnd.out" u 2:1 w lp t "rnd(c)", "./c_mtrnd.out" u 2:1 w lp t "mtrnd(c)", "./go_rnd.out" u 2:1 w lp t "rnd(go)", "./go_mtrnd.out" u 2:1 w lp t "mtrnd(go)"
EOF
