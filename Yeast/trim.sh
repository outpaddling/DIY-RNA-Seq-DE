#!/bin/sh -e

##########################################################################
#   Description:
#       
#   History:
#   Date        Name        Modification
#   2025-03-24  Jason Bacon Begin
##########################################################################

usage()
{
    printf "Usage: $0 raw-file\n"
    exit 64     # sysexits(3) EX_USAGE
}


##########################################################################
#   Main
##########################################################################

if [ $# != 1 ]; then
    usage
fi
raw=$1

output_dir=Results/04-trim
base=$(basename $raw)
trimmed=Results/04-trim/${base%.fastq.zst}-trimmed.fastq.zst
stdout=${trimmed%.fastq.zst}.stdout
stderr=${trimmed%.fastq.zst}.stderr
fastq-trim --3p-adapter1 AGATCGGAAGAG --polya-min-length 3 \
    --min-match 3 --max-mismatch-percent 10 --min-qual 20 --min-length 30 \
    $raw $trimmed > $stdout 2> $stderr
