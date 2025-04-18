#!/bin/sh -e

##########################################################################
#   Description:
#       Run fasda normalize and fold-change on kallisto abundances
##########################################################################

input_dir=Results/10-kallisto-quant
samples=$(ls $input_dir | wc -l)
replicates=$(($samples / 2))

uname -a
fasda --version
pwd

output_dir=Results/11-fasda-kallisto
mkdir -p $output_dir
cd $output_dir

files=$(ls ../../$input_dir/sample*-*/abundance.tsv)
norm_all=all-norm.tsv
echo "fasda normalize --output $norm_all $files"
set -x
time fasda normalize --output $norm_all $files
set +x
printf "\nAll samples normalized counts:\n\n"
head -n 5 $norm_all

