# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("RS# to Gene biomaRt Lookup"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      fileInput("snps.file", label=h3("SNPs file, text RefSNP IDs one-per-line"))
    ),

    # Show a plot of the generated distribution
    mainPanel(
      tableOutput("lookup.results")
    )
  )
))
