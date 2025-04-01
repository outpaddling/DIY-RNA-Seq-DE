#!/usr/bin/env python

# Derived from:
# https://igb.mit.edu/mini-courses/python/data-processing-with-python/seaborn/visualizing-rnaseq-data

import pandas
import numpy
import seaborn
import glob
import matplotlib.pyplot

seaborn.set_context('paper')
seaborn.set_style("whitegrid")

counts = pandas.read_csv('small.tsv',sep='\t')
print(counts.shape)
print(counts.head())
exit(0)

counts.describe()
row_medians = counts.median(axis=1,numeric_only=True)
counts_row_norm = counts.copy()
for col in counts.columns[1:]:
    counts_row_norm[col] = numpy.log2((counts[col]+0.1)/(row_medians+0.1))
counts_row_norm.describe()
counts_row_norm.iloc[1,1:].median() #test some random rows, make sure the median value is 0
counts_row_norm.head()
# counts_row_norm = counts_row_norm.set_index('geneID')
import fastcluster
# seaborn.clustermap(dataset_row_norm, row_cluster=True, col_cluster=False, cmap="RdBu_r", figsize=(10,10))
