#!/usr/bin/env gnuplot

#
# Various ways to create a 2D heat map from ascii data
#

set title "Read counts"
unset key
set tic scale 0

# Color runs from white to green
# set palette rgbformula -7,2,-7
set palette rgbformula 2,-7,-7
set cbrange [0:500]
set cblabel "Counts"
unset cbtics

set xrange [-0.5:5.5]
set yrange [-0.5:9.5]

$map1 << EOD
5 4 3 1 0
2 2 0 0 1
0 0 0 1 0
0 0 0 2 3
0 1 2 4 3
EOD

set view map
splot 'small.tsv' matrix with image
