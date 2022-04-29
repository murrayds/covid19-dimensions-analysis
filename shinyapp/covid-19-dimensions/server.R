#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(ggrepel)
library(DT)


source("org-table.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  # Define a reactive listener to determine whether a row has been selected in 
  # either the COVID-ALL or COVID-VACCINE tables
  table.selection.listener <- reactive({
    list(input$covid.all.table_rows_selected, input$covid.vaccine.table_rows_selected, input$tabSwitch)
  })
 
  
  #
  # Org-Table Outputs
  #
  output$covid.all.table = (generate_org_table(covid.all()))
  
  output$covid.vaccine.table = (generate_org_table(covid.vaccine()))
  
  # 
  # Org-Table Event Observers
  #
  observeEvent(table.selection.listener(), {
    selId <- NA
    if (input$tabSwitch == "All COVID-19 Research") {
      req(input$covid.all.table_rows_selected)
      selId <- covid.all()[input$covid.all.table_rows_selected,]$id
      print(paste("Your selected row:", selId))
    } else {
      req(input$covid.vaccine.table_rows_selected)
      selId <- covid.vaccine()[input$covid.vaccine.table_rows_selected,]$id
      print(paste("Your selected row:", selId))
    }
    
    # Sub-table showing top authors
    output$org.top.authors = generate_sub_table(
      selected.org.top.authors(selId))
    
    # Sub-table showing top funders
    output$org.top.funders = generate_sub_table(
      selected.org.top.funders(selId))
    
    # Sub-table showing top funders
    output$org.top.pubs = generate_sub_table(
      selected.org.top.pubs(selId))
  })
  

})
