# server.R - Bill White - 6/15/17
#
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com

library(shiny)
library(biomaRt) 

shinyServer(function(input, output, session) {

  output$snp.input <- renderUI({
    validate(
      need(!is.null(input$snp.src), "please select a SNP source")
    )
    if(input$snp.src == "list.src") {
      textAreaInput("snps.text", label="SNPs list, one per line", value="rs1048194", rows=10, resize="both")
    } else {
      fileInput("snps.file", label="SNPs file with one RefSNP ID per line")
    }
  })
  
  output$stdout.text <- renderPrint({
    the.snps <- NULL
    if(input$snp.src == "list.src") {
      if(!is.null(input$snps.text)) {
        the.snps <- unlist(strsplit(input$snps.text, "\n"))
      }
    } else {
      if(input$snp.src == "file.src") {
        if(!is.null(input$snps.file)) {
          the.snps <- read.table(input$snps.file$datapath, header=FALSE, stringsAsFactors=FALSE)[, 1]
        }
      }
    }
    if(is.null(the.snps)) {
      return(NULL)
    } 
    cat("Number of SNPs read:", length(the.snps), "\n")
  })
  
  output$lookup.results <- renderTable({
    the.snps <- NULL
    if(input$snp.src == "list.src") {
      if(!is.null(input$snps.text)) {
        print(input$snps.text)
        the.snps <- unlist(strsplit(input$snps.text, "\n"))
        print(the.snps)
      }
    } else {
      if(input$snp.src == "file.src") {
        if(!is.null(input$snps.file)) {
          the.snps <- read.table(input$snps.file$datapath, header=FALSE, stringsAsFactors=FALSE)[, 1]
        }
      }
    }
    if(is.null(the.snps)) {
      return(NULL)
    } 
    
    # lookup the refsnp IDs return the ENSEMBL gene IDs
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
    # load the gene info database
    ensembl2gene.biomart <- useEnsembl(biomart="ensembl", dataset="hsapiens_gene_ensembl")
    snp.gene.info <- getBM(attributes=c('ensembl_gene_id', 'hgnc_symbol', 'description'), 
                           filters='ensembl_transcript_id', 
                           values=map.ensembl.clean$ensembl_transcript_stable_id,
                           uniqueRows=TRUE,
                           mart=ensembl2gene.biomart)
    snp.genes.annot <- cbind(map.ensembl.clean[match(snp.gene.info$ensembl_gene_id, 
                                                     map.ensembl.clean$ensembl_gene_stable_id), 1], 
                             snp.gene.info)
    colnames(snp.genes.annot) <- c("RefSNP", "Ensembl", "Gene", "Description")
    # remove snps with no associated gene symbol
    snp.genes.annot <- snp.genes.annot[snp.genes.annot$Gene != "", ]
    # sort data frame returned by snp then gene ID
    snp.genes.annot[order(snp.genes.annot$RefSNP, snp.genes.annot$Ensembl), ]
  }, bordered=TRUE)

})
