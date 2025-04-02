#!/bin/sh -e

##########################################################################
#   Description:
#       Generate and display heatmap for Kallisto results
#       
#   History:
#   Date        Name        Modification
#   2025-03-31  Jason Bacon Begin
##########################################################################

# Generate a list of features of interest by filtering the FASDA fold-changes
features=filtered-features.txt
fasda filter --max-p-val 0.05 Results/11-fasda-kallisto/fc-3-replicates.txt \
    | awk '{ print $1 }' | head -n 30 > $features
wc -l $features

# FIXME: Update when ./heatmap is moved into PATH
# Add --debug to see Python data structures
fasda heatmap $features Results/11-fasda-kallisto/cond1-norm-3.tsv \
    Results/11-fasda-kallisto/cond2-norm-3.tsv
