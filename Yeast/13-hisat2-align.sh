#!/bin/sh -e

##########################################################################
#   Description:
#       Run hisat2 aligner on each RNA sample.
##########################################################################

##############################################################################
# Align with hisat2, which can handle splice junctions in RNA reads

# Document software versions used for publication
uname -a
hisat2 --version
pwd

build=$(Reference/genome-build.sh)
release=$(Reference/genome-release.sh)
genome=$(Reference/genome-filename.sh)

input_dir=Results/05-trim
output_dir=Results/13-hisat2-align
index_dir=Results/12-hisat2-index
mkdir -p $output_dir
# samtools sort dumps temp files in CWD
cd $output_dir

# Find out how many processors this machine has available
processors=$(getconf _NPROCESSORS_ONLN)

for fastq in ../../$input_dir/sample*-cond*-rep*.fastq.zst; do
    printf "\n===\n"
    # hisat2 cannot directly read zstd compressed files, nor can
    # it read from a pipe (It performs seek operations within the
    # input file, which only work on ordinary files).  So we convert
    # from zstd to gzip just for this stage.  Use minimum gzip compression
    # to make this quick.
    base=$(basename $fastq) # Remove directory path
    gzb=${base%.zst}.gz
    printf "Converting $fastq to gzip format...\n"
    zstdcat $fastq | gzip --fast > $gzb
    
    bam=${gzb%.*.*}.bam
    sample=${gzb%.fastq.gz}
    printf "Running hisat2 $gzb -> $bam...\n"
    set -x
    hisat2 --threads $processors -x ../../$index_dir/$genome -U $gzb \
	| samtools sort > $bam
    set +x
    
    printf "Indexing $bam...\n"
    samtools index $bam
done
