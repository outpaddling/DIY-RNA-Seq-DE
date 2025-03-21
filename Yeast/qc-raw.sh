#!/bin/sh -e

##########################################################################
#   Description:
#       
#   History:
#   Date        Name        Modification
#   2025-03-21  Jason Bacon Begin
##########################################################################

usage()
{
    printf "Usage: $0 fastq-file\n"
    exit 64     # sysexits(3) EX_USAGE
}


##########################################################################
#   Main
##########################################################################

if [ $# != 1 ]; then
    usage
fi
fastq=$1

output_dir=Results/03-qc-raw
base=$(basename $fastq)     # Get filename without directory path
stem=${base%.fastq.*}       # Get filename with .fastq.* removed
zstdcat $fastq | fastqc -o $output_dir stdin:$stem
