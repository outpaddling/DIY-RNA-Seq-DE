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
#   Function description:
#       Pause until user presses return
##########################################################################

pause()
{
    local junk
    
    printf "Press return to continue..."
    read junk
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
wc -l $features
fgrep -f $features Results/11-fasda-kallisto/cond1-norm-3.tsv > cond1-norm-3.tsv
fgrep -f $features Results/11-fasda-kallisto/cond2-norm-3.tsv > cond2-norm-3.tsv
pause

# Concatenate corresponding lines from the normalized counts files
# and remove the 2nd occurrence of the feature name (column 5 in pasted output)
counts=counts.tsv
rm -f $counts
paste cond1-norm-3.tsv cond2-norm-3.tsv \
    | awk '{ printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $3, $4, $6, $7, $8, $9); }' \
    > $counts

# Generate example small file
# To-do: Convert counts to z-scores for realistic color comparison across
# features with different expression levels
printf "Transcript\tc1r1\tc1r2\tc1r3\tc2r1\tc2r2\tc2r3\n" > small.tsv
head -n 30 $counts >> small.tsv
cat small.tsv

# Load the counts into gnuplot and draw a heatmap
# gnuplot --persist heatmap.gnuplot

./heatmap-seaborn.py
