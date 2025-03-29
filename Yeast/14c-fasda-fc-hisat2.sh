#!/bin/sh -e

output_dir=Results/14-fasda-hisat2
mkdir -p $output_dir
cd $output_dir

uname -a
fasda --version
pwd

printf "Computing fold-changes...\n"
set -x
fasda fold-change --output fc.txt cond1-norm.tsv cond2-norm.tsv
set +x

more fc.txt
printf "\n%-25s %10s %10s\n" "File" "Features" "P < 0.05"
printf "%-25s %10s %10s\n" fc.txt: \
	$(cat fc.txt | wc -l) $(awk '$8 < 0.05' fc.txt | wc -l)
