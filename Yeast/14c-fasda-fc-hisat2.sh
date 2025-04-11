#!/bin/sh -e

output_dir=Results/14-fasda-hisat2
mkdir -p $output_dir
cd $output_dir

uname -a
fasda --version
pwd

outfile=fc-3-replicates.txt
export PATH=~/Prog/Src/local/bin:$PATH
printf "Computing fold-changes...\n"
set -x
fasda fold-change --output $outfile cond1-norm.tsv cond2-norm.tsv
set +x

more $outfile
printf "\n%-25s %10s %10s\n" "File" "Features" "P < 0.05"
printf "%-25s %10s %10s\n" $outfile: \
	$(cat $outfile | wc -l) $(awk '$8 < 0.05' $outfile | wc -l)
