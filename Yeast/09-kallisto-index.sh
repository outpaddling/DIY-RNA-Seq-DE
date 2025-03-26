#!/bin/sh -e

##########################################################################
#   Description:
#       Build kallisto index for reference transcriptome.
##########################################################################

# Document software versions used for publication
uname -a
kallisto version
samtools --version
pwd

transcriptome=Results/08-reference/$(Reference/transcriptome-filename.sh)
printf "Using reference $transcriptome...\n"

# Needed for kallisto --genomebam
if [ ! -e $transcriptome.fai ]; then
    printf "Building $transcriptome...\n"
    samtools faidx $transcriptome
fi

printf "Building kallisto index...\n"
output_dir=Results/09-kallisto-index
mkdir -p $output_dir
set -x
kallisto index --index=$output_dir/transcriptome.index $transcriptome
ls -l $output_dir
