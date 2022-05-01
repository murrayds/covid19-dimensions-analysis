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
library(DT)
library(ggwordcloud)
library(plotly)

source("org-table.R")
source("author-table.R")
source("pub-table.R")
source("funder-table.R")
source("concept-projection.R")

generate_main_table <- function(table, selection = "single", scrollable = TRUE, columnDefs = list()) {
  DT::renderDataTable(table,
                      options = list(
                        paging = TRUE,    ## paginate the output
                        pageLength = 15,  ## number of rows to output for each page
                        scrollX = scrollable,   ## enable scrolling on X axis
                        scrollY = scrollable,   ## enable scrolling on Y axis
                        autoWidth = TRUE, ## use smart column width handling
                        server = FALSE,   ## use client-side processing
                        dom = 'Bfrtip',
                        buttons = c('csv', 'excel'),
                        columnDefs = columnDefs
                      ),
                      selection = list(mode = selection, selected = 1),
                      class = "small nowrap",
                      extensions = 'Buttons',
                      escape = FALSE)
}

generate_sub_table <- function(df, columnDefs = list()) {
  DT::renderDataTable(
    df,
    options = list(
      paging = FALSE,    ## paginate the output
      pageLength = 5,  ## number of rows to output for each page
      scrollX = FALSE,   ## enable scrolling on X axis
      scrollY = FALSE,   ## enable scrolling on Y axis
      autoWidth = TRUE, ## use smart column width handling
      server = FALSE, ## use client-side processing
      dom = "t",
      ordering = FALSE,
      bSort = FALSE,
      columnDefs = columnDefs
    ),
    class = "small compact",
    rownames = FALSE,
    selection = "none"
  )
}

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
  
  funder.table.selection.listener <- reactive({
    list(input$funder.covid.all.table_rows_selected, input$funder.covid.vaccine.table_rows_selected, input$funder.tabSwitch)
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
      selId <- org.covid.all()[input$org.covid.all.table_rows_selected,]$id
      print(paste("Your selected row:", selId))
    } else {
      req(input$org.covid.vaccine.table_rows_selected)
      selId <- org.covid.vaccine()[input$org.covid.vaccine.table_rows_selected,]$id
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
  # Author-Table Event Observers
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
    
    # Now populate the treemap & keyword table
    output$author.fields = renderPlot(get_field_treemap(table, selId))
    print("getting author keywords")
    output$author.keywords = generate_sub_table(get_author_keywords(table, selId))
  })
  
  
  #
  # Author-Table Outputs
  #
  observeEvent(input$pub.metric, {
    output$pub.covid.all.table = generate_main_table(generate_pub_table(get_pub_table("all", input$pub.metric)), "none", FALSE)
    output$pub.covid.vaccine.table = generate_main_table(generate_pub_table(get_pub_table("vaccine", input$pub.metric)), "none", FALSE)
  })
  
  
  #
  # Funder-Table Outputs
  #
  output$funder.covid.all.table = generate_main_table(generate_funder_table(get_funder_table_agg("all")), 
                                                      selection = "single", 
                                                      scrollable = FALSE, 
                                                      columnDefs = list(list(targets=3:4, className="dt-right")))
  
  output$funder.covid.vaccine.table = generate_main_table(generate_funder_table(get_funder_table_agg("vaccine")), 
                                                          selection = "single", 
                                                          scrollable = FALSE, 
                                                          columnDefs = list(list(targets=3:4, className="dt-right")))
  
  
  # 
  # Funder-Table Event Observers
  #
  observeEvent(funder.table.selection.listener(), {
    selId <- NA
    topic <- NULL
    if (input$funder.tabSwitch == "All COVID-19 Research") {
      req(input$funder.covid.all.table_rows_selected)
      topic <- "all"
      selId <- get_funder_table_agg("all")[input$funder.covid.all.table_rows_selected,]$funder_org
      print(paste("Your selected row:", selId))
    } else {
      req(input$funder.covid.vaccine.table_rows_selected)
      topic <- "vaccine"
      selId <- get_funder_table_agg("vaccine")[input$funder.covid.vaccine.table_rows_selected,]$funder_org
      print(paste("Your selected row:", selId))
    }
    
    # Sub-table showing the biggest grants associated with each funder
    # NOTE: Commented out, as I thought it wansn't actually that useful
    # output$funder.top.grants = generate_sub_table(genrate_funder_top_grants_table(get_funder_table(topic), selId), columnDefs=list(list(targets=1, className="dt-right")))
    
    # Sub-table showing the top recipients from each funder
    output$funder.recipients = generate_sub_table(genrate_funder_recipient_table(get_recipient_table(topic), selId), columnDefs=list(list(targets=2, className="dt-right")))
    
    # Plots showing the distribution of a funder's support across sectors(first) and countries (second)
    output$funder.recipients.sectors = renderPlot({generate_sector_treemap(selId, topic)})
    output$funder.recipients.countries = renderPlot({generate_country_treemap(selId, topic)})
    
  })
  
  
  output$concept.projection <- renderPlotly({
    ggplotly(generate_concept_projection(), tooltip = "label")
  })
  
  get_country_trends_table_all <- reactive({
    read_delim("/Users/d.murray/Documents/covid19-dimensions-analysis/data/bq-data/temporal/pubs_over_time_covid-all.tsv", delim = "\t")
  })
  
  get_country_trends_table_vaccine <- reactive({
    read_delim("/Users/d.murray/Documents/covid19-dimensions-analysis/data/bq-data/temporal/pubs_over_time_covid-vaccine.tsv", delim = "\t")
  })
  
  
  
  observeEvent(input$trends.country, {
    print(input$trends.country)
    trends_fields_colors <- c("Medical and Health Sciences" = "#e31a1c", 
                              "Studies in Human Society" = "#1f78b4", 
                              "Biological Sciences" = "#b2df8a", 
                              "Mathematical Sciences" = "#33a02c", 
                              "Agricultural and Veterinary Sciences" = "#fb9a99", 
                              "Chemical Sciences" = "#6a3d9a",
                              "Information and Computing Sciences" = "#fdbf6f",
                              "Engineering" = "#ff7f00",
                              "Other" = "grey")
    
    output$trends.country.absolute <- renderPlotly({
      get_country_trends_table_all() %>%
        filter(grepl(input$trends.country, countries, fixed = T)) %>%
        mutate(fields = str_split(fields, ",")) %>%
        select(fields, published_date) %>%
        unnest(fields) %>%
        filter(!is.na(fields)) %>%
        mutate(fields  = ifelse(fields %in% names(trends_fields_colors), fields, "Other")) %>%
        filter(published_date < as.Date("2022-05-01")) %>%
        filter(published_date > as.Date("2020-03-01")) %>%
        mutate(
          published_date = paste(format(published_date, "%Y"),  # Convert dates to quarterly
                                 sprintf("%02i", (as.POSIXlt(published_date)$mon) %/% 3L + 1L), 
                                 sep = "-")
        ) %>%
        group_by(published_date, fields) %>%
        summarize(n = n()) %>%
        group_by(published_date) %>%
        group_by(fields) %>%
        ungroup() %>%
        filter(fields != "Other") %>%
        ggplot(aes(x = published_date, y = n, color = fields, group = fields, label = n)) +
        geom_line() +
        geom_point() +
        #scale_y_log10() +
        scale_color_manual(values = trends_fields_colors) +
        theme_minimal() +
        theme(
          legend.position = "none",
          axis.title.x = element_blank(),
          axis.text.x = element_text(angle = 45, hjust = 1)
        ) +
        ylab("Total")
    })
      
      
    output$trends.country.relative <- renderPlotly({
      get_country_trends_table_all() %>%
        filter(grepl(input$trends.country, countries, fixed = T)) %>%
        mutate(fields = str_split(fields, ",")) %>%
        select(fields, published_date) %>%
        unnest(fields) %>%
        filter(!is.na(fields)) %>%
        mutate(fields  = ifelse(fields %in% names(trends_fields_colors), fields, "Other")) %>%
        filter(published_date < as.Date("2022-05-01")) %>%
        filter(published_date > as.Date("2020-03-01")) %>%
        mutate(
          published_date = paste(format(published_date, "%Y"),  # Convert dates to quarterly
                                 sprintf("%02i", (as.POSIXlt(published_date)$mon) %/% 3L + 1L), 
                                 sep = "-")
        ) %>%
        group_by(published_date, fields) %>%
        summarize(n = n()) %>%
        group_by(published_date) %>%
        mutate(prop = round(n / sum(n) * 100, 3)) %>%
        group_by(fields) %>%
        #filter(mean(prop) > 0.02) %>%
        ungroup() %>%
        filter(fields != "Other") %>%
        ggplot(aes(x = published_date, y = prop, color = fields, group = fields, label = n)) +
        geom_line() +
        geom_point() +
        scale_y_log10() +
        scale_color_manual(values = trends_fields_colors) +
        theme_minimal() +
        theme(
          legend.position = "none",
          axis.title.x = element_blank(),
          axis.text.x = element_text(angle = 45, hjust = 1)
        ) +
        ylab("% of total")
    })
    
  })
  
  

})
