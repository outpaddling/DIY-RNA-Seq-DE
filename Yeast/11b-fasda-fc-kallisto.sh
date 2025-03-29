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

de_file=fc-$replicates-replicates.txt
printf "\nComputing fold-change for $replicates replicates...\n"
echo "time fasda fold-change --output $de_file cond1-norm-$replicates.tsv cond2-norm-$replicates.tsv"
time fasda fold-change \
     --output $de_file \
    cond1-norm-$replicates.tsv cond2-norm-$replicates.tsv

more $de_file
printf "\n%-25s %10s %10s\n" "File" "Features" "P < 0.05"
printf "%-25s %10s %10s\n" $de_file: \
	$(cat $de_file | wc -l) $(awk '$8 < 0.05' $de_file | wc -l)
