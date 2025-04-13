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

# Separate counts by condition for fasda fold-change
norm_all=all-norm.tsv
cols=$(awk 'NR == 1 { print NF }' $norm_all)
last_c1_col=$(($cols / 2 + 1))
first_c2_col=$(($last_c1_col + 1))
echo $cols $last_c1_col $first_c2_col

printf "\nCondition 1 normalized counts:\n"
norm_file1=cond1-norm-$replicates.tsv
cut -f 1-$last_c1_col $norm_all > $norm_file1
head -n 5 $norm_file1

printf "\nCondition 2 normalized counts:\n"
norm_file2=cond2-norm-$replicates.tsv
cut -f 1,$first_c2_col-$cols $norm_all > $norm_file2
head -n 5 $norm_file2

de_file=fc-$replicates.txt
printf "\nComputing fold-change for $replicates replicates...\n"
echo "time fasda fold-change --output $de_file cond1-norm-$replicates.tsv cond2-norm-$replicates.tsv"
time fasda fold-change \
     --output $de_file \
    cond1-norm-$replicates.tsv cond2-norm-$replicates.tsv

more $de_file
printf "\n%-25s %10s %10s\n" "File" "Features" "P < 0.05"
printf "%-25s %10s %10s\n" $de_file: \
	$(cat $de_file | wc -l) $(awk '$8 < 0.05' $de_file | wc -l)
