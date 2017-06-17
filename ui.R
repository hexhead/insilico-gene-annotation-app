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
      fileInput("snps.file", label="SNPs file with one RefSNP ID per line")
    ),

    # Main panel on right side
    mainPanel(
      tableOutput("lookup.results")
    )
  )
))
