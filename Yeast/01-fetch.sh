#!/bin/sh -e

##########################################################################
#   Description:
#       Fetch Yeast sample data and create symlinks with descriptive names
##########################################################################

##########################################################################
#   Main
##########################################################################

# Make sure user specifies how many replicates to download
if [ $# != 1 ]; then
    printf "Usage: $0 replicates\n" >> /dev/stderr
    exit 1
fi
replicates=$1
if [ $replicates -lt 3 ] || [ $replicates -gt 48 ]; then
    printf "$0: Replicates cannot be less than 3 or greater than 48.\n" >> /dev/stderr
    exit 1
fi

# Document software versions used for publication
uname -a
fasterq-dump --version
pwd

raw=Results/01-fetch
mkdir -p $raw

tech_rep=1  # Fixed, could be 1 through 7
for condition in WT SNF2; do
    # Select $replicates replicates
    # Get one technical replicate from each biological replicate
    # Col 2 (Lane) indicates technical rep, use samples where Lane = 1
    # Col 3 is SNF2 mutant or WT
    # Col 4 is biological replicate
    awk -v replicates=$replicates -v condition=$condition -v tech_rep=$tech_rep \
	'$2 == tech_rep && $3 == condition && $4 <= replicates' \
	ERP004763_sample_mapping.tsv > $condition.tsv
    printf "$condition:\n"

    for sample in $(awk '{ print $1 }' $condition.tsv); do
	fq="$sample.fastq.zst"
	# Use 2 digits for all replicates in filenames for easier viewing
	if [ ! -e $raw/$fq ]; then
	    printf "Downloading $sample...\n"
	    prefetch --progress $sample
	    fasterq-dump --progress --outdir $raw $sample
	    rm -rf $sample  # Remove .sra files
	    printf "Compressing...\n"
	    # Run in background so next download can start while this one compresses
	    zstd -f --rm $raw/$sample.fastq &
	fi
    done
    rm -f $condition.tsv
done
wait
ls -l $raw
