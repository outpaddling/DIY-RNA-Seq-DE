#!/bin/sh -e

usage()
{
    printf "Usage: $0 replicates\n"
    exit 1
}

##########################################################################
#   Main
##########################################################################

if [ $# != 1 ] && [ $# != 2 ]; then
    usage
fi
reps=$1
if [ $# = 2 ]; then
    if [ $3 = shifted ]; then
	fetch=01-fetch-shifted.sh
    else
	usage
    fi
else
    fetch=01-fetch.sh
fi

rm -rf Results/05-trim Results/10-kallisto-quant
./$fetch $reps
./02-readable-names.sh $reps
./05-trim.sh | cat
./10-kallisto-quant.sh
./11a-fasda-normalize-kallisto.sh
./11b-fasda-fc-kallisto.sh | cat
./11d-kallisto-deseq2.sh
./11e-fasda-deseq2-overlap.sh
