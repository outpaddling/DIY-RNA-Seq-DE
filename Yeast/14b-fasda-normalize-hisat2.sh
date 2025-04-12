#!/bin/sh -e

output_dir=Results/14-fasda-hisat2
mkdir -p $output_dir
cd $output_dir

uname -a
fasda --version
pwd

# FIXME: Factor out to fasda-mw.sh?
norm_all=all-norm.tsv
printf "Normalizing all samples\n"
files=$(ls *-abundance.tsv)

set -x
fasda normalize --output $norm_all $files
set +x
printf "\nAll samples normalized counts:\n"
head -n 5 $norm_all
