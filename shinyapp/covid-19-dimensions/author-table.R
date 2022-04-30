#
# Functions for working with the author table
#
# author: dakota.s.murray@gmail.com
#

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


# Generate the main table
generate_author_table <- function(df) {
  print("Hello!")
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



get_concept_wordcloud <- function(table) {
  table %>%
    select(concepts) %>%
    mutate(concepts = str_split(concepts, ";")) %>%
    unnest(concepts) %>%
    filter(!concepts %in% c("COVID-19", "SARS-CoV-2", "study", "patients", "infection", "disease", 
                            "results", "data", "analysis", "pandemic", "cases", "vaccine",
                            "virus", "response")) %>%
    group_by(concepts) %>%
    summarize(
      n = n()
    ) %>%
    arrange(desc(n)) %>%
    top_n(20, n) %>%
    mutate(angle = 0) %>%
    ggplot(aes(label = concepts, size = n, color = n)) +
    geom_text_wordcloud_area(shape = "circle") +
    scale_size_area(max_size = 8) +
    scale_color_gradient(low = "black", high = "darkblue") +
    theme_minimal() +
    theme(panel.background = element_rect(fill = NA, size = 0.25, color = "black"))
}