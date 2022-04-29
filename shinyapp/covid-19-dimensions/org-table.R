#
# Functions for working with the organization-table
#
covid.all <- reactive({
  read_delim("/Users/d.murray/Documents/covid19-dimensions-analysis/data/bq-data/leading_orgs/leading_orgs_covid-all.tsv", 
             delim = "\t")
})


covid.vaccine <- reactive({
  read_delim("/Users/d.murray/Documents/covid19-dimensions-analysis/data/bq-data/leading_orgs/leading_orgs_covid-vaccine.tsv", 
             delim = "\t")
})

org.top.authors <- reactive({
  read_delim("/Users/d.murray/Documents/covid19-dimensions-analysis/data/bq-data/leading_orgs/org_top_authors.tsv",
             delim = "\t")
})

selected.org.top.authors <- function(selId) {
  org.top.authors() %>% 
    filter(orgid == selId) %>%
    mutate(Name = paste0(first_name, " ", last_name)) %>%
    select(Name, citations, pubcount) %>%
    rename(`# Papers` = pubcount,
           `# Citations` = citations)
}


org.top.funders <- reactive({
  read_delim("/Users/d.murray/Documents/covid19-dimensions-analysis/data/bq-data/leading_orgs/org_top_funders.tsv",
             delim = "\t")
})

selected.org.top.funders <- function(selId) {
  org.top.funders() %>% 
    filter(orgid == selId) %>%
    group_by(orgid) %>%
    mutate(prop = amount / sum(amount, na.rm = T)) %>%
    top_n(5, amount) %>%
    mutate(
      amount = formatC(amount, format="d", big.mark=","),
      prop = paste0(round(prop * 100, 2), "%")
    ) %>%
    ungroup() %>%
    select(funder_name, amount, prop) %>%
    rename(`Funder` = funder_name,
           `$` = amount,
           `%` = prop )  
}

org.top.pubs <- reactive({
  read_delim("/Users/d.murray/Documents/covid19-dimensions-analysis/data/bq-data/leading_orgs/org_top_pubs.tsv",
             delim = "\t")
})

selected.org.top.pubs <- function(selId) {
  org.top.pubs() %>% 
    filter(orgid == selId) %>%
    select(title, journal_title, times_cited) %>%
    rename(`Title` = title,
           `Journal` = journal_title,
           `Citations` = times_cited)  
}


# Code for generating main orgainzation tables
generate_org_table <- function(df) {
  DT::renderDataTable({
    df %>%
      select(name, country, pubcount, top_10_percent, top_10_percent_prop) %>%
      rename(Organization = name,
             Country = country,
             `# Papers` = pubcount,
             `# Papers (top 10%)` = top_10_percent,
             `% Papers (top 10%)` = top_10_percent_prop)
  },
  options = list(
    paging = TRUE,    ## paginate the output
    pageLength = 10,  ## number of rows to output for each page
    scrollX = TRUE,   ## enable scrolling on X axis
    scrollY = TRUE,   ## enable scrolling on Y axis
    autoWidth = TRUE, ## use smart column width handling
    server = FALSE,   ## use client-side processing
    dom = 'Bfrtip',
    buttons = c('csv', 'excel')
  ),
  selection = list(mode = 'single', selected = c(1)),
  extensions = 'Buttons')
}

# Generates a sub-table
generate_sub_table <- function(df) {
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
      bSort = FALSE
    ),
    class = "medium compact",
    rownames = FALSE,
    selection = "none"
  )
}