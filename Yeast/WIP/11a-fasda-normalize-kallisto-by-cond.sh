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

for condition in 1 2; do
    norm_file=cond$condition-norm-$replicates.tsv
    printf "\nNormalizing condition $condition: $replicates replicates\n"
    files=""
    all_reps=$(ls ../../$input_dir | cut -d - -f3 | cut -c 4-5 | sort | uniq)
    for r in $all_reps; do
	files="$files ../../$input_dir/sample*cond$condition-rep$r*/abundance.tsv"
    done
    echo "fasda normalize --output $norm_file $files"
    time fasda normalize --output $norm_file $files
    printf "\nCondition $condition normalized counts:\n\n"
    head $norm_file
done
