#!/bin/sh -e

input_dir=Results/10-kallisto-quant
samples=$(ls $input_dir | wc -l)
replicates=$(($samples / 2))
output_dir=Results/11-fasda-kallisto
fasda_de_file=$output_dir/fc-$replicates.txt


printf "Total features:                   %s\n" \
	$(wc -l $fasda_de_file | awk '{ print $1 }')

awk '$1 != "Feature" && $8 < 0.05 { print $1 }' \
    $fasda_de_file | sort > fasda-sdegs.txt
printf "SDE features reported by FASDA:   %s\n" \
    $(wc -l fasda-sdegs.txt | awk '{ print $1 }')

deseq_de_file=kallisto-deseq2-results.tsv
awk '$1 != "baseMean" && $6 < 0.05 { print $1 }' \
    $deseq_de_file | sort > deseq-sdegs.txt
printf "SDE features reported by DESeqs:  %s\n" \
    $(wc -l deseq-sdegs.txt | awk '{ print $1 }')

printf "\nCommon to FASDA and DESeq2:       %s\n" \
	$(comm -12 fasda-sdegs.txt deseq-sdegs.txt | wc -l)
printf "Reported only by FASDA:           %s\n" \
	$(comm -23 fasda-sdegs.txt deseq-sdegs.txt | wc -l)
printf "Reported only by DESeq2:          %s\n" \
	$(comm -13 fasda-sdegs.txt deseq-sdegs.txt | wc -l)

