#!/bin/sh -e

##########################################################################
#   Script description:
#       Run kallisto quant on each trimmed FASTQ file
##########################################################################

# Document software versions used for publication
uname -a
fastqc --version
pwd

# Find out how many processors this machine has available
processors=$(getconf _NPROCESSORS_ONLN)

input_dir=Results/05-trim
index_dir=Results/09-kallisto-index
output_dir=Results/10-kallisto-quant

# Don't bother with xargs here to run multiple jobs at once.
# Instead, just loop through the files and use all available cores for one job.
for fastq in $input_dir/*.fastq.zst; do
    printf "===\nProcessing $fastq...\n===\n\n"
    base=$(basename $fastq)     # Get filename without directory path
    stem=${base%.fastq.*}       # Get filename with .fastq.* removed

    # kallisto can't handle zstd and will simply seg fault rather than
    # issue an error message.  Manually decompress the zstd files into
    # a named pipe and let kallisto read from there.
    pipe1=${stem}.fifo
    mkfifo $pipe1 || true
    zstdcat $fastq > $pipe1 &
    
    # Kallisto requires an output subdirectory for each sample
    my_output_dir=$output_dir/$stem
    mkdir -p $my_output_dir
    
    set -x
    kallisto quant \
	--single --fragment-length=190 --sd=10 \
	--threads=$processors \
	--index=$index_dir/transcriptome.index \
	--output-dir=$my_output_dir $pipe1 2>&1
    set +x
    rm -f $pipe1
done
