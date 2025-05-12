#!/bin/sh -e

# This is just an example of how to generate a counts matrix in Bourne
# shell.  kallisto-counts.tsv is not currently used by ./kallisto-deseq2.R,
# which duplicates this code to create a data frame from the kallisto
# abundance files.
cut -f 1 Results/10-kallisto-quant/sample01*/abundance.tsv > kallisto-counts.tsv
for path in Results/10-kallisto-quant/*/abundance.tsv; do
    # Example dir name: sample01-cond1-rep01-trimmed
    # Sample is characters 7 and 8
    dir=$(echo $path | cut -d / -f 3)
    sample=$(echo $dir | cut -c 7-8)
    # Extract column 4 (counts) from one abundance.tsv file and
    # add it to kallisto-counts.tsv
    cut -f 4 $path | sed -e "s|est_counts|s$sample|" \
	| paste kallisto-counts.tsv - > temp.tsv
    mv temp.tsv kallisto-counts.tsv
done
head kallisto-counts.tsv

./kallisto-deseq2.R

de_file=kallisto-deseq2-results.tsv
printf "\n%-25s %10s %10s %11s\n" "File" "Features" "P < 0.05" "Padj < 0.05"
printf "%-25s %10s %10s %11s\n" $de_file: \
	$(cat $de_file | wc -l) \
	$(awk '$5 < 0.05' $de_file | wc -l) \
	$(awk '$6 < 0.05' $de_file | wc -l)
