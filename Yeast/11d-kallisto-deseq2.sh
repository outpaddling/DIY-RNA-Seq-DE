#!/bin/sh -e

# FIXME: This only currently works for 3 samples

# FIXME: Move creation of kallisto-counts.tsv to kallisto-deseq2.R so that
# this is more representative of a typical DESeq2 analysis.
cut -f 1 Results/10-kallisto-quant/sample01*/abundance.tsv > kallisto-counts.tsv
sample=1
for file in Results/10-kallisto-quant/*/abundance.tsv; do
    cut -f 4 $file | sed -e "s|est_counts|s$sample|" | paste kallisto-counts.tsv - > temp.tsv
    mv temp.tsv kallisto-counts.tsv
    sample=$(($sample + 1))
done
head kallisto-counts.tsv
./kallisto-deseq2.R

de_file=kallisto-deseq2-results.tsv
printf "\n%-25s %10s %10s %11s\n" "File" "Features" "P < 0.05" "Padj < 0.05"
printf "%-25s %10s %10s %11s\n" $de_file: \
	$(cat $de_file | wc -l) \
	$(awk '$5 < 0.05' $de_file | wc -l) \
	$(awk '$6 < 0.05' $de_file | wc -l)
