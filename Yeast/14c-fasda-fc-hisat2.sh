#!/bin/sh -e

output_dir=Results/14-fasda-hisat2
mkdir -p $output_dir
cd $output_dir

uname -a
fasda --version
pwd

# Separate counts by condition for fasda fold-change
norm_all=all-norm.tsv
printf "\nCondition 1 normalized counts:\n"
norm_file1=cond1-norm.tsv
cut -f 1-4 $norm_all > $norm_file1
head -n 5 $norm_file1

printf "\nCondition 2 normalized counts:\n"
norm_file2=cond2-norm.tsv
cut -f 1,5-7 $norm_all > $norm_file2
head -n 5 $norm_file2

outfile=fc-3.txt
# export PATH=~/Prog/Src/local/bin:$PATH
printf "Computing fold-changes...\n"
set -x
fasda fold-change --output $outfile cond1-norm.tsv cond2-norm.tsv
set +x

more $outfile
printf "\n%-25s %10s %10s\n" "File" "Features" "P < 0.05"
printf "%-25s %10s %10s\n" $outfile: \
	$(cat $outfile | wc -l) $(awk '$8 < 0.05' $outfile | wc -l)
