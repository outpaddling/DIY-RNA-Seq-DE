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

files=""
all_samples=$(ls ../../$input_dir | cut -d - -f1 | cut -c 7-8 | sort | uniq)
echo $all_samples
for s in $all_samples; do
    files="$files ../../$input_dir/sample$s-*/abundance.tsv"
done
ls $files | cat
norm_all=all-norm.tsv
echo "fasda normalize --output $norm_all $files"
time fasda normalize --output $norm_all $files

printf "\nCondition 1 normalized counts:\n"
norm_file1=cond1-norm-$replicates.tsv
cut -f 1-4 $norm_all > $norm_file1
head $norm_file1

printf "\nCondition 2 normalized counts:\n"
norm_file2=cond2-norm-$replicates.tsv
cut -f 1,5-7 $norm_all > $norm_file2
head $norm_file2
