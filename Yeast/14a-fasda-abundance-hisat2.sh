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
