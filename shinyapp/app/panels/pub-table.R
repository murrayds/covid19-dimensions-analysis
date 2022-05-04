#
# Functions for working with the publications table
#
# author: dakota.s.murray@gmail.com
#

#
# HELPERS
#
createDoiLink <- function(doi, text) {
  sprintf('<a href="https://www.doi.org/%s">%s</a>', doi, text)
}


#
# DATA GETTERS
#
get_pub_table <- function(topic, metric) {
  return(read_delim(paste0("data/bq-data/leading_pubs/leading_pubs_covid-",
                           topic,
                           "_",
                           metric,
                           ".tsv"),
                    delim = "\t"))
}


#
# Table constructor
#
generate_pub_table <- function(table) {
  table %>%
    mutate(
      pub_title = str_trunc(pub_title, width = 80, side = "right"),
      pub_title = createDoiLink(doi, pub_title)
    ) %>%
    select(pub_title, journal_title, year, citations, altmetrics) %>%
    rename(Title = pub_title,
           Journal = journal_title,
           Year = year,
           Citations = citations,
           Altmetrics = altmetrics)

}
