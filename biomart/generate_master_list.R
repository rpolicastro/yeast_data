#!/usr/bin/env Rscript

library("tidyverse")

##############################
## Generating Gene Master List
##############################

## Import and clean biomart results
## ----------

biomart <- read.delim("./reference_files/biomart_features.tsv", sep="\t", header=T, stringsAsFactors=F) %>% as_tibble

## Biomart sometimes excludes genes if certain cateories are select
## Find excluded genes and try to get as many categories as possible before they drop out

# find excluded genes
no.biomart <- read.delim("../genome/gtf_genes.tsv", sep="\t", header=F, stringsAsFactors=F) %>%
	dplyr::rename("Gene.stable.ID"=1) %>%
	filter(!(Gene.stable.ID %in% (biomart %>% pull(Gene.stable.ID) %>% unique)))

# write excluded genes to file
write.table(
	no.biomart, "./results/no_biomart_features.tsv",
	sep="\t", col.names=F, row.names=F, quote=F, na=""
)

# load up biomart results of genes that were initially excluded
biomart.redo <- read.delim("./reference_files/biomart_features_unknown.tsv", sep="\t", header=T, stringsAsFactors=F) %>% as_tibble

# add them back to main biomart list
biomart <- bind_rows(biomart, biomart.redo) %>% arrange(Gene.stable.ID)

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
## ----------

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

## Get list of excluded genes
## ----------

excluded <- biomart %>%
	filter(
		gene_type %in% c("tRNA", "rRNA", "pseudogene") |
		is.na(gene_type) |
		chr == "Mito" |
		grepl(gene_description, pattern="Dubious open reading frame")
	)

write.table(
	excluded, "./results/genes_to_exclude.tsv",
	sep="\t", col.names=T, row.names=F, quote=F, na=""
)

## Export master list
## ----------

# write to file
write.table(
	biomart, "./results/gene_master_list.tsv",
	sep="\t", col.names=T, row.names=F, quote=F, na=""
)

## Log
## ----------

log.file <- "./results/LOG.txt"

## Header

write("
################################
## Log file for gene master list
################################
", file=log.file, append=F
)

## Gene info

n.ygd_id <- nrow(biomart)
n.gene_name <- biomart %>% filter(gene_name != "" & !is.na(gene_name)) %>% nrow
n.ncbi_id <- biomart %>% filter(NCBI_ID != "" & !is.na(NCBI_ID)) %>% nrow

write(paste(
"## Gene info
## ----------

YGD_ID:", n.ygd_id,
"\nGene_name:", n.gene_name,
"\nNCBI_ID:", n.ncbi_id
), file=log.file, append=T
)

## Gene types

gene.types <- biomart %>% count(gene_type) %>% arrange(desc(n))

write("
## Gene types
## ----------
", file=log.file, append=T
)

write.table(gene.types, log.file, sep=": ", col.names=F, row.names=F, quote=F, na="", append=T)

dubious.orfs <- biomart %>% filter(grepl(gene_description, pattern="Dubious open reading frame")) %>% nrow

write(paste("
Dubious ORFs:", dubious.orfs
), file=log.file, append=T
)

## Chromosome info

chr.info <- biomart %>% count(chr) %>% arrange(desc(n))

write("
## Chromosome info
## ----------
", file=log.file, append=T
)

write.table(chr.info, log.file, sep=": ", col.names=F, row.names=F, quote=F, na="", append=T)
