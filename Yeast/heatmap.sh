#!/bin/sh -e

##########################################################################
#   Title:
#       Optional, defaults to the name of the script sans extention
#
#   Section:
#       Optional, defaults to 1
#
#   Synopsis:
#       
#   Description:
#       
#   Arguments:
#       
#   Returns:
#
#   Examples:
#
#   Files:
#
#   Environment:
#
#   See also:
#       
#   History:
#   Date        Name        Modification
#   2025-03-31  Jason Bacon Begin
##########################################################################

usage()
{
    printf "Usage: $0\n"
    exit 64     # sysexits(3) EX_USAGE
}


##########################################################################
#   Main
##########################################################################

if [ $# != 0 ]; then
    usage
fi

# Generate a list of features of interest by filtering the FASDA fold-changes
features=filtered-features.txt
fasda filter --max-p-val 0.05 Results/11-fasda-kallisto/fc-3-replicates.txt \
    | awk '{ print $1 }' > $features

# Concatenate corresponding lines from the normalized counts files
# and remove the 2nd occurrence of the feature name
counts=counts.csv
rm -f $counts
paste Results/11-fasda-kallisto/cond1-norm-3.tsv \
    Results/11-fasda-kallisto/cond2-norm-3.tsv \
    | awk '{ printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $3, $4, $6, $7, $8, $9); }' \
    > $counts

# Load the counts into gnuplot and draw a heatmap
head $counts > small.tsv
cat small.tsv
gnuplot --persist heatmap.gnuplot
