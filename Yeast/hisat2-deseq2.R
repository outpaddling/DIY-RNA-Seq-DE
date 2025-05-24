#!/usr/bin/env Rscript

##########################################################################
#   Script description:
#       Minimal script for estimating fold-changes and P-values on
#       hisat2 output using DESeq2.
#
#   Reference with explanations of each step:
#       https://ashleyschwartz.com/posts/2023/05/deseq2-tutorial
#       
#   History:
#   Date        Name        Modification
#   2025-04-13  Jason Bacon Begin
##########################################################################

##########################################################################
# Input file must be TSV and look like this:
# target_id       s1      s2      s3      s4      s5      s6
# YPL071C_mRNA    14      32      30      51      36      36
# YLL050C_mRNA    238     433     344     831     676     631
# YMR172W_mRNA    42.6436 62.4375 46.8129 121.99  100.89  103.369
#
# Column labels are not important.
# First 3 columns are condition 1 (control in DESeq2 design)
# Last 3 are condition 2 (treated in DESeq2 design)
##########################################################################

##########################################################################
#   Extract est_counts column from every hisat2 abundance file and
#   combine them into a single matrix.
##########################################################################

setwd("Results/14-fasda-hisat2")
# Getr list of subdirectories such as sample01-cond1-rep01-trimmed
abundance_files = dir(pattern="*-abundance.tsv")
print(abundance_files)
for (index in 1:length(abundance_files)){
    file = abundance_files[index]
    print(file)
    data = read.table(file, header=TRUE, sep="\t")
    # Extract counts column
    counts_n = as.data.frame(data$est_counts)
    colnames(counts_n)[1] = paste("s", index, sep="")
    
    if ( index == 1 )
    {
	# For first file, create data frame and add row names
	raw_counts = counts_n
	rownames(raw_counts) = data$target_id
    }
    else
    {
	# For the rest of the files, add the counts as another column
	raw_counts = cbind(raw_counts, counts_n)
    }
    
    # R allocates new memory every time a variable is assigned, even if
    # it already exists, so free unused data frames immediately
    rm(data)
}
print(head(raw_counts))
setwd("../..")

# Alternative: Use counts.tsv file created externally
# row.names=1 removes "target_id" label from col 1, so it is not
# counted as a data column.
# raw_counts = read.delim("hisat2-counts.tsv", row.names=1, header=TRUE)
# print(head(raw_counts))
# quit()

print("Raw counts:")
head(raw_counts)
cols = ncol(raw_counts)
print(paste("cols = ", cols))

##########################################################################
#   Compare DESeq2 normalization
#   https://scienceparkstudygroup.github.io/research-data-management-lesson/median_of_ratios_manual_normalization/index.html
##########################################################################

print("Normalizing with DESeq2...")

# DESeqDataSetFromMatrix() can only handle integers.  Seriously??
# Hisat2 and other quantifiers output real numbers.
raw_counts = round(raw_counts)

# Create an "experimental design" data frame describing which columns
# represent each condition.
sample_names = c(colnames(raw_counts))
# Must be called "condition" for DESeqDataSetFromMatrix()
# Old code for fixed 3-replicate studies
# condition = c("control", "control", "control", "treated", "treated", "treated")
# Generalized code for any number of replicates
condition = c(rep("control", cols/2), rep("treated", cols/2))
meta_data = data.frame(sample_names, condition)

# Drop "1", "2", ... and just keep sample names and associated conditions
library(tibble)
meta_data <- meta_data %>% remove_rownames %>% 
	     column_to_rownames(var="sample_names")
meta_data

# Sanity checks: Should print TRUE TRUE
all(colnames(raw_counts) %in% rownames(meta_data))
all(colnames(raw_counts) == rownames(meta_data))

# Reclaim memory used by library we're done with
# This won't make much difference here, but it's a good habit to form
# as other scripts may use a lot of memory
unloadNamespace("tibble")

# create a DESeqDataSet object.  See docs for possible designs.
# Typical is a 2-condition experiment.
library(DESeq2)
dds = DESeqDataSetFromMatrix(countData = raw_counts, colData = meta_data,
			     design = ~condition)
dds

# Compute normalized counts: The dds var is not actually used by DESeq2,
# just informational.  DESeq() will normalize again internally.
# Compute median ratio normalization scaling factors
dds = estimateSizeFactors(dds)
# Extract scaling factors from DESeqDataSet into standard data frame.
scaling_factors = sizeFactors(dds)
scaling_factors
normalized_deseq2 = counts(dds, normalized = TRUE)
write.table(normalized_deseq2, file='hisat2-deseq2-normalized-counts.tsv',
	    sep = '\t', quote=F, col.names = NA)

# Since we had to round the counts to integers to let DESeq2 use them,
# they won't be quite the same as the manually normalized counts.  Rather
# than compare them, which will yield mostly FALSE values, just display
# them for visual comparison.  They should be about the same.
head(normalized_deseq2)
tail(normalized_deseq2)

# Run DESeq2 differential analysis to produce fold-changes and P-values.
dds = DESeq(dds)
results = results(dds)
results
write.table(results, file='hisat2-deseq2-results.tsv', sep='\t', quote=F,
	    col.names=NA)
