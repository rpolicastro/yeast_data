#!/bin/bash

## Filter based on biomart exclusions
## ----------

## get excluded genes

EXCLUSIONS=($(awk 'NR>1{print $1}' ../../biomart/results/genes_to_exclude.tsv))

## turn excluded genes to regexp

REGEXP=$(echo ${EXCLUSIONS[@]} | tr " " "|")

## filter GTF using regexp

mkdir -p ../filtered_gtfs

grep -vE "$REGEXP" ../Saccharomyces_cerevisiae.R64-1-1.96.gtf > ../filtered_gtfs/Saccharomyces_cerevisiae.R64-1-1.96.Filtered.gtf

## make GTFs based on annotation type
## ----------

BIOTYPES=($(grep -oE "gene_biotype \"[A-Za-z_]+\"" ../Saccharomyces_cerevisiae.R64-1-1.96.gtf | sort | uniq | cut -d " " -f 2 | grep -oE "[A-Za-z_]+"))

for BIOTYPE in ${BIOTYPES[@]};
do
	grep -E "^\#\!" ../Saccharomyces_cerevisiae.R64-1-1.96.gtf > ../filtered_gtfs/Saccharomyces_cerevisiae.R64-1-1.96.${BIOTYPE}.gtf
	grep -E "gene_biotype \"${BIOTYPE}\"" ../Saccharomyces_cerevisiae.R64-1-1.96.gtf >> ../filtered_gtfs/Saccharomyces_cerevisiae.R64-1-1.96.${BIOTYPE}.gtf
done

## Filter mitochondrial genes
## ----------

awk 'NR<=5 || $1 == "Mito"' ../Saccharomyces_cerevisiae.R64-1-1.96.gtf > \
../filtered_gtfs/Saccharomyces_cerevisiae.R64-1-1.96.Mitochondrial.gtf

## Filter dubious open reading frames
## ----------

DUBIOUS=($(grep -E "Dubious open reading frame" ../../biomart/results/gene_master_list.tsv | cut -f1))
REGEX=$(echo ${DUBIOUS[@]} | tr " " "|")

grep -E "^\#\!" ../Saccharomyces_cerevisiae.R64-1-1.96.gtf > ../filtered_gtfs/Saccharomyces_cerevisiae.R64-1-1.96.Dubious_ORFs.gtf
grep -E "$REGEX" ../Saccharomyces_cerevisiae.R64-1-1.96.gtf >> ../filtered_gtfs/Saccharomyces_cerevisiae.R64-1-1.96.Dubious_ORFs.gtf
