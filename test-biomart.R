# test-biomart.R - Bill White - 6/15/17
#
# Use biomaRt to lookup genes fromm SNP refsnp IDs (GWAS "hits").
#
# R version 3.3.3 (2017-03-06)
# Platform: x86_64-pc-linux-gnu (64-bit)
# Running under: Debian GNU/Linux 8 (jessie)

# biomaRt_2.26.1
library(biomaRt) 

rm(list=ls())

snps.file <- "top-snps.txt"
# lookup the refsnp IDs in this file and return the ENSEMBL IDs
the.snps <- read.table(snps.file, header=FALSE, stringsAsFactors=FALSE)[, 1]
# load the SNP info database
snp2ensembl.biomart<- useMart("ENSEMBL_MART_SNP", dataset="hsapiens_snp")
snp.id.info <- getBM(c("refsnp_id", "ensembl_gene_stable_id", "ensembl_transcript_stable_id",
                       "chr_name", "chrom_start", "chrom_end"),
                     filters="snp_filter",
                     values=the.snps,
                     uniqueRows=FALSE,
                     mart=snp2ensembl.biomart)
map.ensembl.clean <- snp.id.info[snp.id.info$ensembl_gene_stable_id != "", ]

#uniq.ensembl <- snp.id.info[which(snp.id.info$ensembl_gene_stable_id %in% unique(snp.id.info$ensembl_gene_stable_id)), ]
# lookup the ENSEMBL ID and get the gene symbol
ensembl2gene.biomart <- useEnsembl(biomart="ensembl", dataset="hsapiens_gene_ensembl")
snp.gene.info <- getBM(attributes=c('ensembl_gene_id', 'hgnc_symbol'), 
                       filters='ensembl_transcript_id', 
                       values=map.ensembl.clean$ensembl_transcript_stable_id,
                       uniqueRows=TRUE,
                       mart=ensembl2gene.biomart)
#orig.snps.subset <- match(snp.gene.info$ensembl_gene_id, snp2ensembl.biomart$ensembl_gene_stable_id)
#mapped.snps <- snp.id.info[match(snp.gene.info$ensembl_gene_id, snp.id.info$ensembl_gene_stable_id), 1]
snp.genes.annot <- cbind(map.ensembl.clean[match(snp.gene.info$ensembl_gene_id, map.ensembl.clean$ensembl_gene_stable_id), 1], 
                         snp.gene.info)
colnames(snp.genes.annot) <- c("RefSNP", "Ensembl", "Gene")
snp.genes.annot <- snp.genes.annot[snp.genes.annot$Gene != "", ]
snp.genes.annot[order(snp.genes.annot$RefSNP, snp.genes.annot$Ensembl), ]
