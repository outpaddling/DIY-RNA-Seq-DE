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

output_dir=Results/10-kallisto-quant
base=$(basename $fastq)     # Get filename without directory path
stem=${base%.fastq.*}       # Get filename with .fastq.* removed

# kallisto can't handle zstd and will simply seg fault rather than
# issue an error message.  Manually decompress the zstd files into
# a named pipe and let kallisto read from there.
pipe1=${stem}.fifo
mkfifo $pipe1 || true
zstdcat $zst1 > $pipe1 &

# Kallisto requires an output subdirectory for each sample
stem=$(basename ${zst1%.fastq.zst})
my_output_dir=$output_dir/$stem
mkdir -p $my_output_dir

set -x
kallisto quant \
    --single --fragment-length=190 --sd=10 \
    --threads=$LPJS_THREADS_PER_PROCESS \
    --index=$index_dir/transcriptome.index \
    --output-dir=$my_output_dir $pipe1 2>&1 | tee $log
rm -f $pipe1
