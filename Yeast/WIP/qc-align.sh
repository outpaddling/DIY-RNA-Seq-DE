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
    printf "Usage: $0 bam-file\n"
    exit 64     # sysexits(3) EX_USAGE
}


##########################################################################
#   Main
##########################################################################

if [ $# != 1 ]; then
    usage
fi
bam=$1

output_dir=Results/14-qc-align
base=$(basename $bam)     # Get filename without directory path
stem=${base%.bam.*}       # Get filename with .bam.* removed
fastqc -o $output_dir $bam \
    > $output_dir/$stem.stdout 2> $output_dir/$stem.stderr
