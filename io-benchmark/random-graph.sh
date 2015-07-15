#!/bin/sh

org="f1"

cat random-graph.cmd | gnuplot
sed "s/$org/f0.5/g" random-graph.cmd | gnuplot
sed "s/$org/f0.25/g" random-graph.cmd | gnuplot
sed "s/$org/f0.125/g" random-graph.cmd | gnuplot
sed "s/$org/f0.0625/g" random-graph.cmd | gnuplot
sed "s/$org/f0.03125/g" random-graph.cmd | gnuplot
