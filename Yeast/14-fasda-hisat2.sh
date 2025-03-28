#!/bin/sh -e

reference_dir=Results/08-reference
hisat2_dir=Results/13-hisat2-align
output_dir=Results/14-fasda-hisat2
gff=$(Reference/gff-filename.sh)

mkdir -p $output_dir
cd $output_dir

uname -a
fasda --version
pwd

##########################################################################
#   Compute abundances
##########################################################################

for bam in ../../$hisat2_dir/*.bam; do
    base=$(basename $bam)
    ab=${base%.bam}-abundance.tsv
    set -x
    fasda abundance --output-dir . 51 ../../$reference_dir/$gff $bam
    set +x
    # column is a Unix command that formats tabular data into consistent columns
    # for viewing
    column -t $ab | head
    wc $ab
done

# FIXME: Factor out to fasda-mw.sh?
for condition in 1 2; do
    norm_file=cond$condition-all-norm.tsv
    if [ ! -e $norm_file ]; then
	printf "Normalizing condition $condition: $replicates replicates\n"
	files=""
	files=$(ls *-cond$condition-*-abundance.tsv)
	printf "%s\n" $files
	set -x
	fasda normalize --output $norm_file $files
	set +x
    fi
    printf "\nCondition $condition normalized counts:\n\n"
    head $norm_file
done

printf "Computing fold-change for $replicates replicates...\n"
set -x
fasda fold-change --output fc.txt cond1-all-norm.tsv cond2-all-norm.tsv
set +x

pwd
ls
more fc.txt
printf "\n%-25s %10s %10s\n" "File" "Features" "P < 0.05"
printf "%-25s %10s %10s\n" fc.txt: \
	$(cat fc.txt | wc -l) $(awk '$8 < 0.05' fc.txt | wc -l)
