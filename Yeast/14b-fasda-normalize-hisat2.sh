#!/bin/sh -e

output_dir=Results/14-fasda-hisat2
mkdir -p $output_dir
cd $output_dir

uname -a
fasda --version
pwd

# FIXME: Factor out to fasda-mw.sh?
for condition in 1 2; do
    norm_file=cond$condition-all-norm.tsv
    printf "Normalizing condition $condition: $replicates replicates\n"
    files=""
    files=$(ls *-cond$condition-*-abundance.tsv)
    printf "%s\n" $files
    set -x
    fasda normalize --output $norm_file $files
    set +x
    printf "\nCondition $condition normalized counts:\n\n"
    head $norm_file
done
