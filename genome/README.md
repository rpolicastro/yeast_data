
# *S. cerevisiae* Genome

## About

- **Annotation**: Ensembl R64-1-1.96
- **Assembly**: Ensembl R64-1-1

Downloaded from Ensembl on 06-25-2019

## Files

#### Scripts
- **get_genes.R**: Extract genes from GTF anntotation file.
- **filter_by_exclusions.sh**: Remove genes marked as exclusions from the biomart analysis.

#### Raw
- **Saccharomyces_cerevisiae.R64-1-1.96.gtf**: Genomic annotation.
- **Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.fa**: Genomic assembly.

#### Processed
- **Saccharomyces_cerevisiae.R64-1-1.96.Filtered.gtf**: Genomic annotations with genes from the biomart exclusions file removed.
Gene types filtered include rRNA, tRNA, Mitochondrial genes, pseudogenes, and dubious ORFs.
- **Saccharomyces_cerevisiae.R64-1-1.96.protein_coding.gtf**: Annotated protein coding genes.
- **Saccharomyces_cerevisiae.R64-1-1.96.rRNA.gtf**: Annotated rRNA genes.
- **Saccharomyces_cerevisiae.R64-1-1.96.tRNA.gtf**: Annotated tRNA genes.
- **Saccharomyces_cerevisiae.R64-1-1.96.ncRNA.gtf**: Annotated ncRNA genes.
- **Saccharomyces_cerevisiae.R64-1-1.96.pseudogenes.gtf**: Annotated pseudogenes.
- **Saccharomyces_cerevisiae.R64-1-1.96.snoRNA.gtf**: Annotated snoRNA genes.
- **Saccharomyces_cerevisiae.R64-1-1.96.snRNA.gtf**: Annotated snRNA genes.
