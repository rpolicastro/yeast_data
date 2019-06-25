#!/usr/bin/env Rscript

library("GenomicFeatures")
library("tidyverse")

####################
## Get Genes in GTF
####################

gtf.genes <- makeTxDbFromGFF(
		"../genome/Saccharomyces_cerevisiae.R64-1-1.96.gtf",
		"gtf"
	) %>%
	genes %>%
	names %>%
	unique %>%
	as_tibble

write.table(
	gtf.genes, "gtf_genes.tsv",
	sep="\t", col.names=F, row.names=F, quote=F
)
