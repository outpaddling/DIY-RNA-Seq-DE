#!/usr/bin/env Rscript

##########################################################################
#   Script description:
#       Derived from:
#       https://github.com/Roslin-Aquaculture/RNA-Seq-kallisto?tab=readme-ov-file#4-differential-expression-using-DESeq2
#       
#   Arguments:
#       
#   Returns:
#       
#   History:
#   Date        Name        Modification
#   2025-03-31  Jason Bacon Begin
##########################################################################

library(rhdf5)
library(tximportData)
library(tximport)
library(readr)
library(biomaRt)
library(DESeq2)
library(PCAtools)
library(EnhancedVolcano)
library("pheatmap")

dir <- 
