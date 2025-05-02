#!/usr/bin/env Rscript

##########################################################################
#   Script description:
#       Minimal script for estimating fold-changes and P-values on
#       kallisto output using DESeq2.
#
#   Reference with explanations of each step:
#       https://ashleyschwartz.com/posts/2023/05/deseq2-tutorial
#       
#   History:
#   Date        Name        Modification
#   2025-04-13  Jason Bacon Begin
##########################################################################

library(tibble)

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

# FIXME: Convert kallisto outputs to counts.tsv

# row.names=1 removes "target_id" label from col 1, so it is not
# counted as a data column.
raw_counts = read.delim("kallisto-counts.tsv", row.names=1, header=TRUE)
print("Raw counts:")
head(raw_counts)
cols = ncol(raw_counts)
print(paste("cols = ", cols))

##########################################################################
#   Compare DESeq2 normalization
#   https://scienceparkstudygroup.github.io/research-data-management-lesson/median_of_ratios_manual_normalization/index.html
##########################################################################

print("Normalizing with DESeq2...")
library(DESeq2)

# DESeqDataSetFromMatrix() can only handle integers.  Seriously??
# Kallisto and other quantifiers output real numbers.
raw_counts = round(raw_counts)

# Create an "experimental design" data frame describing which columns
# represent each condition.
sample_names = c(colnames(raw_counts))
# Must be called "condition" for DESeqDataSetFromMatrix()
condition = c("control", "control", "control", "treated", "treated", "treated")
meta_data = data.frame(sample_names, condition)
# Drop "1", "2", ... and just keep sample names and associated conditions
meta_data <- meta_data %>% remove_rownames %>% 
	     column_to_rownames(var="sample_names")
meta_data

# Sanity checks: Should print TRUE TRUE
all(colnames(raw_counts) %in% rownames(meta_data))
all(colnames(raw_counts) == rownames(meta_data))

# create a DESeqDataSet object.  See docs for possible designs.
# Typical is a 2-condition experiment.
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
write.table(normalized_deseq2, file='kallisto-deseq2-normalized-counts.tsv',
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
write.table(results, file='kallisto-deseq2-results.tsv', sep='\t', quote=F,
	    col.names=NA)
