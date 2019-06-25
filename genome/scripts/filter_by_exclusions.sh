#!/bin/bash

## get excluded genes

EXCLUSIONS=($(awk 'NR>1{print $1}' ../biomart/genes_to_exclude.tsv))

## turn excluded genes to regexp

REGEXP=$(echo ${EXCLUSIONS[@]} | tr " " "|")

## filter GTF using regexp

mkdir -p ./filtered_gtfs

grep -vE "$REGEXP" ../Saccharomyces_cerevisiae.R64-1-1.96.gtf > ../filtered_gtfs/Saccharomyces_cerevisiae.R64-1-1.96.Filtered.gtf
