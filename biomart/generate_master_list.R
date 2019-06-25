#!/usr/bin/env Rscript

library("tidyverse")

##############################
## Generating Gene Master List
##############################

## Import biomart results

biomart <- read.delim("./reference_files/biomart_features.tsv", sep="\t", header=T, stringsAsFactors=F) %>% as_tibble

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

human.orthologs <- read.delim("./reference_files/human_orthologs.tsv", sep="\t", header=T, stringsAsFactors=F) %>%
	as_tibble %>%
	dplyr::rename(
		"YGD_ID"=Gene.stable.ID,
		"human_gene_ID"=Human.gene.stable.ID,
		"human_gene_name"=Human.gene.name,
		"yeast_gene_similarity"=X.id..query.gene.identical.to.target.Human.gene,
		"ortholog_confidence"=Human.orthology.confidence..0.low..1.high.
	) %>%
	filter(ortholog_confidence == 1) %>%
	dplyr::select(-ortholog_confidence) %>%
	group_by(YGD_ID) %>%
	summarize_all(~ paste0(., collapse=";")) %>%
	replace(., .=="NA", "")

biomart <- left_join(biomart, human.orthologs, by="YGD_ID")

## Get list of excluded genes

excluded <- biomart %>%
	filter(
		gene_type == "" |
		is.na(gene_type) |
		chr == "Mito" |
		grepl(gene_description, pattern="Dubious open reading frame")
	)

write.table(
	excluded, "./results/genes_to_exclude.tsv",
	sep="\t", col.names=T, row.names=F, quote=F, na=""
)

## export master list

# reorder columns
biomart <- biomart %>%
	dplyr::select(
		YGD_ID, gene_name, NCBI_ID,
		chr, start, end, strand,
		gene_type, gene_description,
		human_gene_ID, human_gene_name, yeast_gene_similarity,
		interpro_ID, interpro_description,
		GO_slim_ID, GO_slim_description
	)

# write to file
write.table(
	biomart, "./results/gene_master_list.tsv",
	sep="\t", col.names=T, row.names=F, quote=F, na=""
)
