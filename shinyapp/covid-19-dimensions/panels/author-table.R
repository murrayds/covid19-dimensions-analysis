#
# Functions for working with the author table
#
# author: dakota.s.murray@gmail.com
#

#
# 
#
fields_levels <- c("Medical and Health Sciences", "Studies in Human Society", "Biological Sciences", "Mathematical Sciences", "Agricultural and Veterinary Sciences", "Psychology and Cognitive Sciences", "Information and Computing Sciences", "Other")

fields_colors <- c("Medical and Health Sciences" = "#e7298a", 
                   "Studies in Human Society" = "#7570b3", 
                   "Psychology and Cognitive Sciences" = "#e6ab02",
                   "Biological Sciences" = "#d95f02", 
                   "Mathematical Sciences" = "#66a61e", 
                   "Agricultural and Veterinary Sciences" = "#1b9e77", 
                   "Information and Computing Sciences" = "#a6761d",
                   "Other" = "grey")


#
# DATA GETTERS
#
get_author_table <- function(topic, metric) {
  return(read_delim(paste0("/Users/d.murray/Documents/covid19-dimensions-analysis/data/bq-data/leading_authors/leading_authors_covid-",
                           topic, 
                           "_", 
                           metric,
                           ".tsv"), 
                    delim = "\t"))
}

get_concept_freq <- reactive({
  read_delim("/Users/d.murray/Documents/covid19-dimensions-analysis/data/bq-data/concept_frequencies.tsv", delim = "\t") %>% 
    group_by(concept) %>% 
    summarize(n = sum(n)) %>%
    mutate(prop = n / sum(n)) %>%
    ungroup() %>%
    filter(!concept %in% c("COVID-19", "coronavirus disease 2019", "COVID-19 vaccination", "vaccination", "COVID-19 pandemic", "study", "SARS-CoV-2", "vaccine"))
})

#
# TABLE BUILDERS
#
get_selected_author_top_pubs <- function(selId, table) {
  table %>%
    filter(researcher_id == selId) %>%
    select(titles, journal_titles, citations_1) %>%
    mutate(
      titles = str_split(titles, ";"),
      journal_titles = str_split(journal_titles, ";"),
      citations_1 = str_split(str_trim(gsub("\\[|\\]|\\s+", " ", citations_1)), " ")
    ) %>%
    unnest(c(titles, journal_titles, citations_1)) %>%
    mutate(citations_1 = as.numeric(citations_1)) %>%
    rename(Title = titles,
           Journal = journal_titles,
           Citations = citations_1) %>%
    arrange(desc(Citations))
  
}

generate_author_table <- function(df) {
  DT::renderDataTable({
    df %>%
      mutate(name = paste0(first_name, " ", last_name)) %>%
      select(name, org_name, org_country, pubcount, citations, altmetrics) %>%
      rename(Name = name,
             Affiliation = org_name,
             Country = org_country,
             `# Papers` = pubcount,
             `# Citations` = citations,
             `Altmetrics` = altmetrics)
  },
  options = list(
    paging = TRUE,    ## paginate the output
    pageLength = 15,  ## number of rows to output for each page
    scrollX = TRUE,   ## enable scrolling on X axis
    scrollY = TRUE,   ## enable scrolling on Y axis
    autoWidth = TRUE, ## use smart column width handling
    server = FALSE,   ## use client-side processing
    dom = 'Bfrtip',
    buttons = c('csv', 'excel')
  ),
  selection = list(mode = 'single', selected = c(1)),
  class = "small nowrap",
  extensions = 'Buttons')
}


get_author_keywords <- function(table, selId) {
  table %>%  
    filter(researcher_id == selId) %>%
    mutate(concepts = str_split(concepts, ";")) %>%
    select(concepts)%>%
    unnest(concepts) %>%
    group_by(concepts) %>%
    summarize(n = n()) %>%
    ungroup() %>%
    distinct(.keep_all = T) %>%
    mutate(prop = n / sum(n)) %>%
    inner_join(get_concept_freq(), by = c("concepts" = "concept")) %>%
    mutate(diff = prop.x - prop.y) %>%
    arrange(desc(diff)) %>%
    top_n(16, prop.x)  %>%
    select(concepts) %>%
    rename(Concept = concepts)
}

#
# PLOT BUILDERS
#
get_field_treemap <- function(table, selId) {
  table %>%
    filter(researcher_id == selId) %>%
    select(fields) %>%
    mutate(fields = str_split(fields, ";")) %>%
    unnest(fields) %>%
    mutate(fields = ifelse(fields %in% fields_levels, fields, "Other")) %>%
    group_by(fields) %>%
    summarize(n = n()) %>%
    arrange(desc(n)) %>%
    mutate(prop = n / sum(n)) %>%
    ggplot(aes(area = prop, fill = fields, label = str_wrap(fields, width = 15))) +
    geom_treemap(color = "black") +
    geom_treemap_text(colour = "white", 
                      place = "centre",
                      grow = TRUE) +
    theme_void() +
    scale_fill_manual(values = fields_colors) +
    theme(legend.position = "none")
}