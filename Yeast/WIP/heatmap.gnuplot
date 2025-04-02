#!/usr/bin/env gnuplot

#
# Various ways to create a 2D heat map from ascii data
#

set title "Read counts"
unset key
set tic scale 0

# Color runs from white to green
# set palette rgbformula -7,2,-7
# Color runs from white to red
set palette rgbformula 2,-7,-7

# Z value range
set cbrange [0:500]
set cblabel "Counts"

# Don't show z values next to color bar
# unset cbtics

# Edges of plot in x-y coordinates
# To-do: Show feature names and sample numbers instead of x/y
set xrange [-0.5:5.5]
set yrange [-0.5:9.5]

set view map
splot 'small.tsv' matrix with image
