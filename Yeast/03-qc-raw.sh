#!/bin/sh -e

##########################################################################
#   Script description:
#       Run quality checks on raw and trimmed data for comparison
#       Based on work of Dr. Andrea Rau:
#       https://github.com/andreamrau/OpticRegen_2019
#
#       All necessary tools are assumed to be in PATH.  If this is not
#       the case, add whatever code is needed here to gain access.
#       (Adding such code to your .bashrc or other startup script is
#       generally a bad idea since it's too complicated to support
#       every program with one environment.)
#
#   History:
#   Date        Name        Modification
#   2019-09-13  Jason Bacon Begin
##########################################################################

# Document software versions used for publication
uname -a
fastqc --version
pwd

# Find out how many processors this machine has available
processors=$(getconf _NPROCESSORS_ONLN)

mkdir -p Results/03-qc-raw
printf "Running fastqc on each of the following:\n"
find Results/02-readable-names -name 'sample*'

# xargs will run ./qc-raw.sh once for each file output by find.
# It will run up to "$processors" processes at the same time.
# You can also use GNU parallel in place of xargs, if you have it.
# xargs is a standard Unix tool that does what we need here.
# GNU parallel is much more sophisticated, overkill for out purposes.
find Results/02-readable-names -name 'sample*' \
    | xargs -n 1 -P $processors ./qc-raw.sh
