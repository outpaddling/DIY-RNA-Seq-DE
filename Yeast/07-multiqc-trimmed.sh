#!/bin/sh -e

#########################################################################
#   Description:
#   MultiQC is optional, but helpful for visualizing raw read quality
#   and trimming results
#
#   Dependencies:
#       Requires raw FastQC results.  Run after *-qc-raw.lpjs.
##########################################################################

##########################################################################
#   Main
##########################################################################

# multiqc: LC_ALL and LANG must be set to a UTF-8 character set
# in your environment in order for the click module to function.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

input_dir=Results/06-qc-trimmed
output_dir=Results/07-multiqc-trimmed
mkdir -p $output_dir

multiqc --version
multiqc --outdir $output_dir $input_dir
