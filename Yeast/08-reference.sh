#!/bin/sh -e

##########################################################################
#   Description:
#       Build reference genome and transcriptome for all aligners.
##########################################################################

# Document software versions used for publication
uname -a
samtools --version
gffread --version
blt --version
pwd

#############################################################################
# There are multiple possible transcriptome references that can be used with
# kallisto.
#
# There are many gene IDs referenced in the GTF/GFF that are not in the CDNA.
# FIXME: Document the reason for this.  Are these predicted genes?
#
# There are a few gene IDs in the release 98 CDNA that are not in the GFF.
# If downstream analysis involved looking up genes in the GFF, this could
# result in a few misses.  This caused minor problems for CNC-EMDiff, which
# used CDNA as the reference.
#
# More importantly, the CDNA does not document features such as exons, UTRs,
# etc.  If downstream analysis will examine such features, use the GTF/GFF.

# macOS zcat looks for .Z extension, while Linux does not have gzcat
zcat='gunzip -c'
fetch='curl -O'

# All analysis stages must use the exact same references, so define it
# in one place (i.e. Reference/genome-build.sh, etc.) and code all scripts
# to take it from there.
build=$(Reference/genome-build.sh)
release=$(Reference/genome-release.sh)
genome=$(Reference/genome-filename.sh)
transcriptome=$(Reference/transcriptome-filename.sh)
gff=$(Reference/gff-filename.sh)

# Chromosome files
output_dir=Results/08-reference
mkdir -p $output_dir
cd $output_dir

#############################################################################
# Download selected chromosomes and concatenate, rather than download
# the entire genome.  The genome often contains things we don't care
# about, such as X and Y chromosomes in mammals, or unassembled genome
# regions in less established model organisms.
#############################################################################

# This yeast data set uses Roman numerals for chromosome numbers, a
# practice that is thankfully rare.
for chrom in I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI; do
    file=Saccharomyces_cerevisiae.R$build.dna.chromosome.$chrom.fa.gz
    if [ ! -e $file ]; then
	$fetch http://ftp.ensembl.org/pub/release-$release/fasta/saccharomyces_cerevisiae/dna/$file
    fi
done

if [ ! -e $genome ]; then
    printf "Concatenating chromosome FASTAs...\n"
    n=1
    for chrom in I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI; do
	printf "$chrom "
	# Convert Roman chromosome numbers to Arabic
	$zcat Saccharomyces_cerevisiae.R$build.dna.chromosome.$chrom.fa.gz \
	    | sed -e "s|^>$chrom|>$n|" -e "s|:$chrom|:$n|" >> $genome
	n=$((n + 1))
    done
    printf "\n"
else
    printf "Using existing $genome...\n"
fi

if [ ! -e $genome.fai ]; then
    printf "Creating index $genome.fai...\n"
    samtools faidx $genome      # Speed up gffread
fi

##########################################################################
# The transcriptome can be built using the genome and a feature file
# (GTF or GFF) that contain locations of all known features such as
# genes, transcripts, and exons.  This approach will ensure that later
# analysis stages using the GTF/GFF file will match all the features
# we mapped our reads to.  The cDNA may not contain the exact same
# features as the GTF/GFF, though this usually is not a major problem.
##########################################################################

# Building a transcriptome from GTF and genome is a bit of a pain
# due to the sort order of the GTF.  We just the Ensembl cDNA and remove
# mitochondria for simplicity, since this is just for demonstration.
awk='awk'   # mawk is faster, but not installed on all systems
cdna=Saccharomyces_cerevisiae.R$build.cdna.all.fa.gz
if [ ! -e $cdna ]; then
    $fetch ftp://ftp.ensembl.org/pub/release-$release/fasta/saccharomyces_cerevisiae/cdna/$cdna
else
    printf "$cdna already exists.  Remove and rerun to replace.\n"
fi
# Each entry in the FASTA file begins with a header like this:
# >I dna:chromosome chromosome:R64-1-1:I:1:230218:1 REF
# keep-autosomes.awk removes lines with "Mito:" in the 3rd field
$zcat $cdna | $awk -F : -f ../../Reference/keep-autosomes.awk > $transcriptome

site=http://ftp.ensembl.org/pub/release-$release/gff3/saccharomyces_cerevisiae

# Download chromosome I gff and keep the header.
file=Saccharomyces_cerevisiae.R64-1-1.106.chromosome.I.gff3.gz
if [ ! -e $file ]; then
    printf "Fetching $file...\n"
    $fetch $site/$file
fi
$zcat $file | blt deromanize 1 > $gff

# Download GFFs for the rest of the chromosomes and append them to the
# main GFF without the header.
for chrom in II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI; do
    file=Saccharomyces_cerevisiae.R64-1-1.106.chromosome.$chrom.gff3.gz
    if [ ! -e $file ]; then
	printf "Fetching $file...\n"
	$fetch $site/$file
    fi
    $zcat $file | egrep -v '^##[a-z]|^#!' | blt deromanize 1 >> $gff
done

# Build transcriptome from GFF and genome
gffread -w ${transcriptome%.fa}-from-gff.fa -g $genome $gff
samtools faidx ${transcriptome%.fa}-from-gff.fa

# Kallisto requires a list of chromosome sizes.  Use the biolibc-tools
# chrom-lens command to generate this from the genome reference.
chrom_lengths="chromosome-sizes.tsv"
printf "Generating $chrom_lengths...\n"
blt chrom-lens < $(../../Reference/genome-filename.sh) > $chrom_lengths
cat $chrom_lengths
