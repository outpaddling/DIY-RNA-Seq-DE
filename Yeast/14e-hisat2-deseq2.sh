#!/bin/sh -e

# This is just an example of how to generate a counts matrix in Bourne
# shell.  hisat2-counts.tsv is not currently used by ./hisat2-deseq2.R,
# which duplicates this code to create a data frame from the hisat2
# abundance files.
cut -f 1 Results/14-fasda-hisat2/sample01*-abundance.tsv > hisat2-counts.tsv
for path in Results/10-hisat2-quant/*/abundance.tsv; do
    # Example dir name: sample01-cond1-rep01-trimmed
    # Sample is characters 7 and 8
    dir=$(echo $path | cut -d / -f 3)
    sample=$(echo $dir | cut -c 7-8)
    # Extract column 4 (counts) from one abundance.tsv file and
    # add it to hisat2-counts.tsv
    cut -f 4 $path | sed -e "s|est_counts|s$sample|" \
	| paste hisat2-counts.tsv - > temp.tsv
    mv temp.tsv hisat2-counts.tsv
done
head hisat2-counts.tsv

./hisat2-deseq2.R

de_file=hisat2-deseq2-results.tsv
printf "\n%-25s %10s %10s %11s\n" "File" "Features" "P < 0.05" "Padj < 0.05"
printf "%-25s %10s %10s %11s\n" $de_file: \
	$(cat $de_file | wc -l) \
	$(awk '$5 < 0.05' $de_file | wc -l) \
	$(awk '$6 < 0.05' $de_file | wc -l)
