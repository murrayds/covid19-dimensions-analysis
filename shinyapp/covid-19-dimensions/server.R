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
library(ggwordcloud)


source("org-table.R")
source("author-table.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  # Define a reactive listener to determine whether a row has been selected in 
  # either the COVID-ALL or COVID-VACCINE tables
  org.table.selection.listener <- reactive({
    list(input$org.covid.all.table_rows_selected, input$org.covid.vaccine.table_rows_selected, input$org.tabSwitch)
  })
  
  author.table.selection.listener <- reactive({
    list(input$author.covid.all.table_rows_selected, input$author.covid.vaccine.table_rows_selected, input$author.tabSwitch)
  })
  
  
  
  #
  # Org-Table Outputs
  #
  output$org.covid.all.table = (generate_org_table(org.covid.all()))
  
  output$org.covid.vaccine.table = (generate_org_table(org.covid.vaccine()))
  
  # 
  # Org-Table Event Observers
  #
  observeEvent(org.table.selection.listener(), {
    selId <- NA
    if (input$org.tabSwitch == "All COVID-19 Research") {
      req(input$org.covid.all.table_rows_selected)
      selId <- covid.all()[input$org.covid.all.table_rows_selected,]$id
      print(paste("Your selected row:", selId))
    } else {
      req(input$org.covid.vaccine.table_rows_selected)
      selId <- covid.vaccine()[input$org.covid.vaccine.table_rows_selected,]$id
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
  
  #
  # Author-Table Outputs
  #
  observeEvent(input$author.metric, {
    output$author.covid.all.table = generate_author_table(get_author_table("all", input$author.metric))  
    output$author.covid.vaccine.table = generate_author_table(get_author_table("vaccine", input$author.metric))
  })
  
  
  # 
  # Org-Table Event Observers
  #
  observeEvent(author.table.selection.listener(), {
    selId <- NA
    table <- NULL
    if (input$author.tabSwitch == "All COVID-19 Research") {
      req(input$author.covid.all.table_rows_selected)
      table <- get_author_table("all", input$author.metric)
      selId <- table[input$author.covid.all.table_rows_selected,]$researcher_id
      print(paste("Your selected row:", selId))
    } else {
      req(input$author.covid.vaccine.table_rows_selected)
      table <- get_author_table("vaccine", input$author.metric)
      selId <- table[input$author.covid.vaccine.table_rows_selected,]$researcher_id
      print(paste("Your selected row:", selId))
    }
    
    # Sub-table showing the most cited publications of selected author
    output$author.top.pubs = generate_sub_table(get_selected_author_top_pubs(selId, table))
    
    # Now populate the wordcloud
    set.seed(1111)
    output$author.wordcloud = renderPlot(get_concept_wordcloud(table))
    
  })
  
  

})
