#!/bin/sh -e

input_dir=Results/10-kallisto-quant
samples=$(ls $input_dir | wc -l)
replicates=$(($samples / 2))
output_dir=Results/11-fasda-kallisto
fasda_de_file=$output_dir/fc-$replicates.txt
awk '$1 != "Feature" && $8 < 0.05 { print $1 }' \
    $fasda_de_file | sort > fasda-sdegs.txt
wc -l fasda-sdegs.txt

deseq_de_file=kallisto-deseq2-results.tsv
awk '$1 != "baseMean" && $6 < 0.05 { print $1 }' \
    $deseq_de_file | sort > deseq-sdegs.txt
wc -l deseq-sdegs.txt

printf "SDEGS common to FASDA and DESeq2: %s\n" \
	$(comm -12 fasda-sdegs.txt deseq-sdegs.txt | wc -l)
printf "SDEGS reported only by FASDA:     %s\n" \
	$(comm -23 fasda-sdegs.txt deseq-sdegs.txt | wc -l)
printf "SDEGS reported only by DESeq2:    %s\n" \
	$(comm -13 fasda-sdegs.txt deseq-sdegs.txt | wc -l)

