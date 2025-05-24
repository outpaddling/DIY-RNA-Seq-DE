#!/bin/sh -e

case $# in
0)
    p=0.05
    ;;
1)
    p=$1
    ;;
*)
    printf "Usage: $0 [P-value cutoff]\n"
    exit 1
    ;;
esac

input_dir=Results/14-fasda-hisat2
samples=$(ls $input_dir/*-abundance.tsv | wc -l)
replicates=$(($samples / 2))
output_dir=Results/14-fasda-hisat2
fasda_de_file=$output_dir/fc-$replicates.txt

printf "Replicates:                       %s\n" $replicates
printf "Total features:                   %s\n" \
	$(wc -l $fasda_de_file | awk '{ print $1 }')

awk -v p=$p '$1 != "Feature" && $8 < p { print $1 }' \
    $fasda_de_file | sort > fasda-sdegs.txt
fasda_sde=$(wc -l fasda-sdegs.txt | awk '{ print $1 }')
printf "P < %4.2f reported by FASDA:       %s\n" $p $fasda_sde

deseq_de_file=hisat2-deseq2-results.tsv
awk -v p=$p '$1 != "baseMean" && $6 < p { print $1 }' \
    $deseq_de_file | sort > deseq-sdegs.txt
deseq2_sde=$(wc -l deseq-sdegs.txt | awk '{ print $1 }')
printf "P < %4.2f by DESeq2:               %s\n" $p $deseq2_sde

common=$(comm -12 fasda-sdegs.txt deseq-sdegs.txt | wc -l)
printf "\nCommon to FASDA and DESeq2:       %s\n" $common
	
fasda_only=$(comm -23 fasda-sdegs.txt deseq-sdegs.txt | wc -l)
printf "Reported only by FASDA:           %s\n" $fasda_only

deseq2_only=$(comm -13 fasda-sdegs.txt deseq-sdegs.txt | wc -l)
printf "Reported only by DESeq2:          %s\n" $deseq2_only

overlap=$((100 * $common / ($common + $fasda_only + $deseq2_only) ))
printf "\nOverlap = Common / (Common + FASDA-only + DESeq2-only)\n"
printf "Overlap:                          %s%%\n" $overlap
rm -f deseq-sdegs.txt fasda-sdegs.txt
