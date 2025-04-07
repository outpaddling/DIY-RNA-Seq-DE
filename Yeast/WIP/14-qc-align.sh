#!/bin/sh -e

##########################################################################
#   Script description:
#       Run quality checks on alignments.
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

# Use variables to make the code self-documenting and easy to change
input_dir=Results/13-hisat2-align
output_dir=Results/14-qc-align

mkdir -p $output_dir
printf "Running fastqc on each of the following:\n"
find $input_dir -name 'sample*.bam'
printf "Please wait...\n"

# xargs will run ./qc-raw.sh once for each file output by find.
# It will run up to "$processors" processes at the same time.
# You can also use GNU parallel in place of xargs, if you have it.
# xargs is a standard Unix tool that does what we need here.
# GNU parallel is much more sophisticated, overkill for out purposes.
find $input_dir -name 'sample*.bam' \
    | xargs -n 1 -P $processors ./qc-align.sh

cat $output_dir/*.std* | more
