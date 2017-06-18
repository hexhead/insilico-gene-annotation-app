# ui.R - Bill White - 6/15/17
#
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("RefSNP ID to Gene Symbol biomaRt Lookup"),

  # Sidebar on left side
  sidebarLayout(
    sidebarPanel(
      radioButtons("snp.src", "SNP source:",
                   c("List" = "list.src",
                     "File upload" = "file.src")),
      textAreaInput("snps.text", label="SNPs list, one per line", value="rs1048194", rows=10, resize="both"),
      fileInput("snps.file", label="OR, SNPs file with one RefSNP ID per line"),
      verbatimTextOutput("stdout.text")
    ),

    # Main panel on right side
    mainPanel(
      tableOutput("lookup.results")
    )
  )
))
