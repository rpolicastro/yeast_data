#!/usr/bin/env Rscript

library("tidyverse")

##############################
## Generating Gene Master List
##############################

## Import biomart results

biomart <- read.delim("biomart_features.tsv", sep="\t", header=T, stringsAsFactors=F) %>% as_tibble

## Add genes without biomart annotation

no.biomart <- read.delim("../genome/gtf_genes.tsv", sep="\t", header=F, stringsAsFactors=F) %>%
	dplyr::rename("Gene.stable.ID"=1) %>%
	filter(!(Gene.stable.ID %in% (biomart %>% pull(Gene.stable.ID) %>% unique)))

biomart <- bind_rows(biomart, no.biomart) %>% arrange(Gene.stable.ID)

## Clean annotations

biomart <- biomart %>%
	dplyr::rename(
		"YGD_ID"=Gene.stable.ID,
		"gene_name"=Gene.name,
		"NCBI_ID"=NCBI.gene.ID,
		"chr"=Chromosome.scaffold.name,
		"start"=Gene.start..bp.,
		"end"=Gene.end..bp.,
		"strand"=Strand,
		"gene_type"=Gene.type,
		"gene_description"=Gene.description,
		"interpro_ID"=Interpro.ID,
		"interpro_description"=Interpro.Description,
		"GO_slim_ID"=GOSlim.GOA.Accession.s.,
		"GO_slim_description"="GOSlim.GOA.Description"
	) %>%
	mutate(strand = case_when(
		strand == -1 ~ "-",
		strand == 1 ~ "+"
	)) %>%
	group_by(YGD_ID) %>%
	summarize_all(~ paste0(
		unique(.) %>%
			discard(is.na(.) | . == "") %>%
			discard(. %in% c("biological_process", "cellular_component", "molecular_function")) %>%
			discard(. %in% c("GO:0008150", "GO:0003674", "GO:0005575")),
		collapse=";"
	))

## Add human orthologs
