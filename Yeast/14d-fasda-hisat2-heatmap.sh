#!/bin/sh -e

##########################################################################
#   Description:
#       Generate and display heatmap for Kallisto results
#       
#   History:
#   Date        Name        Modification
#   2025-03-31  Jason Bacon Begin
##########################################################################

input_dir=Results/13-hisat2-align
samples=$(ls $input_dir/*.bam | wc -l)
replicates=$(($samples / 2))

# Generate a list of features of interest by filtering the FASDA fold-changes
features=filtered-features.txt
fasda filter --max-p-val 0.05 Results/14-fasda-hisat2/fc-$replicates.txt \
    | awk '{ print $1 }' | head -n 30 > $features
wc -l $features

# FIXME: Update when ./heatmap is moved into PATH
# Add --debug to see Python data structures
fasda heatmap $features Results/14-fasda-hisat2/cond1-norm-$replicates.tsv \
    Results/14-fasda-hisat2/cond2-norm-$replicates.tsv
