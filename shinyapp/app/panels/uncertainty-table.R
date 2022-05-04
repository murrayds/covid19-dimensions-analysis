#
# Functions for working with the uncertainty table
#
# author: dakota.s.murray@gmail.com
#

#
# HELPERS
#
#createDoiLink <- function(doi, text) {
#  sprintf('<a href="https://www.doi.org/%s">%s</a>', doi, text)
#}


#
# DATA GETTERS
#
get_uncertainty_table <- reactive({
  read_delim("data/bq-data/disagreement/dimensions_comments.tsv", delim = "\t")
})

get_intext_disagreement <- reactive({
  read_delim("data/bq-data/disagreement/s2orc_disagreement_counts.tsv", delim = "\t")
})


#
# Table constructor
#
generate_uncertainty_table <- function(table) {
  table %>%
    mutate(
      pub_title = str_trunc(pub_title, width = 80, side = "right"),
      pub_title = createDoiLink(doi, pub_title),
      journal_title = str_wrap(journal_title, width = 30),
    ) %>%
    select(pub_title, journal_title, year, citations) %>%
    rename(Title = pub_title,
           Journal = journal_title,
           Year = year,
           Citations = citations) %>%
    arrange(desc(Citations))
  
}

generate_disagreement_plot <- function(table) {
  table %>%
    filter(pub_count > 20) %>%
    mutate(field_name = str_wrap(field_name, width = 24)) %>%
    mutate(field_name = reorder(field_name, prop)) %>%
    ggplot(aes(x = field_name, y = prop)) +
    geom_segment(aes(x = field_name, xend = field_name, y = 0, yend = prop), size = 0.25) +
    geom_point(size = 4, alpha = 0.9, shape = 21, fill = "grey") +
    coord_flip() +
    theme_minimal() +
    theme(
      text = element_text(size = 14),
      axis.title.y = element_blank(),
      panel.background = element_rect(size = 0.25, color = 'black', fill = NA),
      panel.grid.minor = element_blank(),
      panel.grid.major.y = element_blank()
    ) +
    ylab("Proportion of disagreement sentences")
}
