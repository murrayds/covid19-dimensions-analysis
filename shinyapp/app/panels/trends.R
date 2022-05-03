#
# Trends over time
#
# author: dakota.s.murray@gmail.com
#


trends_fields_colors <- c("Medical and Health Sciences" = "#e31a1c",
                          "Studies in Human Society" = "#1f78b4",
                          "Biological Sciences" = "#b2df8a",
                          "Mathematical Sciences" = "#33a02c",
                          "Agricultural and Veterinary Sciences" = "#fb9a99",
                          "Chemical Sciences" = "#6a3d9a",
                          "Information and Computing Sciences" = "#fdbf6f",
                          "Engineering" = "#ff7f00",
                          "Other" = "grey")
#
# DATA GETTERS
#
get_country_table_all <- reactive({
  read_delim("data/bq-data/temporal/pubs_over_time_covid-all.tsv", delim = "\t")
})

get_country_table_vaccine <- reactive({
  read_delim("data/bq-data/temporal/pubs_over_time_covid-vaccine.tsv", delim = "\t")
})


#
# PLOT BUILDERS
#
generate_absolute_trends_plot <- function(table, country) {
  table %>%
    filter(country == "All" | grepl(country, countries, fixed = T)) %>%
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
}


generate_relative_trends_plot <- function(table, country) {
  table %>%
    filter(country == "All" | grepl(country, countries, fixed = T)) %>%
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
    scale_color_manual(values = trends_fields_colors) +
    theme_minimal() +
    theme(
      legend.position = "none",
      axis.title.x = element_blank(),
      axis.text.x = element_text(angle = 45, hjust = 1)
    ) +
    ylab("% of total")
}
