# Biomart Annotations of Yeast Genes

## About

This analysis results in a gene 'master list' that contains useful information about the genes annotated in Ensembl 64-1-1.96

#### Information

- SGD gene ID, gene name, and NCBI gene ID.
- Chromosome, start position, end position, and strand.
- Gene type and gene description.
- Human ortholog Ensembl ID, human ortholog name, and yeast gene similarity (%) to human ortholog.
- Interpro ID and interpo description.
- GO slim ID and GO slim term description.

## Files

#### Reference Files

- **biomart_features.tsv**: Biomart features for majority of genes.
- **biomart_features_unknown.tsv**: Biomart features for genes that originally did not have matches. Biomart sometimes excludes genes when certain return categories are selected.
- **human_orthologs.tsv**: human orthologs to the yeast genes.

#### Results

- **LOG.txt**: Basic information on gene number, gene types, and chromosomal compositions.
- **gene_master_list.tsv**: Final gene master list with columns described above.
- **genes_to_exclude**: Genes that are recommended to be ignored for poly-A selected RNA-seq analysis. This includes rRNA, tRNA, mitochondrial genes, pseudogenes, and dubious ORFs.
- **no_biomart_features.tsv**: Genes that were originally excluded in the biomart results, but were reanalyzed and readed later with compatible return categories selected.
