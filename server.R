
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(biomaRt) 

shinyServer(function(input, output) {

  output$lookup.results <- renderTable({
    in.snps <- input$snps.file
    if(is.null(in.snps)) {
      return(NULL)
    }
    
    # load the database
    snp.db <- useMart("ENSEMBL_MART_SNP", dataset="hsapiens_snp")
    
    # lookup the refsnp ID in this file and return the ENSEMBL ID
    the.snps <- read.table(in.snps$datapath, header=FALSE, stringsAsFactors=FALSE)[, 1]
    snp2ensembl.biomart <- getBM(c("refsnp_id", "ensembl_gene_stable_id"),
                                 filters="snp_filter",
                                 values=the.snps,
                                 mart=snp.db)
    
    # lookup the ENSEMBL ID and get the gene symbol
    ensembl2gene.biomart <- useEnsembl(biomart="ensembl", dataset="hsapiens_gene_ensembl")
    snp.genes <- getBM(attributes=c('ensembl_gene_id', 'ensembl_transcript_id',
                                    'hgnc_symbol', 'chromosome_name', 'start_position',
                                    'end_position'), 
                       filters='ensembl_gene_id', 
                       values=snp2ensembl.biomart,
                       mart=ensembl, 
                       uniqueRows=TRUE)
    snp.genes
  })

})
