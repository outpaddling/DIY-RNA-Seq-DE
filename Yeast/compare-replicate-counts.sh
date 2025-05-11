#!/bin/sh -e

##########################################################################
#   Description:
#       Rerun key stages with various numbers of replicates
#       
#   History:
#   Date        Name        Modification
#   2025-03-27  Jason Bacon Begin
##########################################################################

usage()
{
    printf "Usage: $0 min-replicates max-replicates [shifted]\n"
    exit 1
}


##########################################################################
#   Function description:
#       Pause until user presses return
##########################################################################

pause()
{
    local junk
    
    printf "Press return to continue..."
    read junk
}


##########################################################################
#   Main
##########################################################################

if [ $# != 2 ] && [ $# != 3 ]; then
    usage
fi
min_reps=$1
max_reps=$2
if [ $# = 3 ]; then
    if [ $3 = shifted ]; then
	arg3=shifted
    else
	usage
    fi
fi

for reps in $(seq $min_reps $max_reps); do
    ./reanalyze.sh $reps $arg3
    pause
done
