# server.R - Bill White - 6/15/17
#
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com

library(shiny)
library(biomaRt) 

shinyServer(function(input, output) {

  output$lookup.results <- renderTable({
    in.snps <- input$snps.file
    if(is.null(in.snps)) {
      return(NULL)
    }
    # lookup the refsnp IDs in this file and return the ENSEMBL IDs
    the.snps <- read.table(in.snps$datapath, header=FALSE, stringsAsFactors=FALSE)[, 1]
    # load the SNP info database
    snp2ensembl.biomart<- useMart("ENSEMBL_MART_SNP", dataset="hsapiens_snp")
    snp.id.info <- getBM(c("refsnp_id", "ensembl_gene_stable_id", "ensembl_transcript_stable_id",
                           "chr_name", "chrom_start", "chrom_end"),
                         filters="snp_filter",
                         values=the.snps,
                         uniqueRows=FALSE,
                         mart=snp2ensembl.biomart)
    map.ensembl.clean <- snp.id.info[snp.id.info$ensembl_gene_stable_id != "", ]
    # lookup the ENSEMBL ID and get the gene symbol
    ensembl2gene.biomart <- useEnsembl(biomart="ensembl", dataset="hsapiens_gene_ensembl")
    snp.gene.info <- getBM(attributes=c('ensembl_gene_id', 'hgnc_symbol'), 
                           filters='ensembl_transcript_id', 
                           values=map.ensembl.clean$ensembl_transcript_stable_id,
                           uniqueRows=TRUE,
                           mart=ensembl2gene.biomart)
    snp.genes.annot <- cbind(map.ensembl.clean[match(snp.gene.info$ensembl_gene_id, 
                                                     map.ensembl.clean$ensembl_gene_stable_id), 1], 
                             snp.gene.info)
    colnames(snp.genes.annot) <- c("RefSNP", "Ensembl", "Gene")
    snp.genes.annot <- snp.genes.annot[snp.genes.annot$Gene != "", ]
    snp.genes.annot[order(snp.genes.annot$RefSNP, snp.genes.annot$Ensembl), ]
  })

})
