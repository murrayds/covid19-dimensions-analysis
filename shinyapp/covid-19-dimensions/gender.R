#
# Trends over time
#
# author: dakota.s.murray@gmail.com
#

#
# DATA GETTERS
#
get_gender_table_all <- reactive({
  read_delim("/Users/d.murray/Documents/covid19-dimensions-analysis/data/derived/gender/authors_with_gender_covid-all.tsv", delim = "\t")
})

get_gender_table_vaccine <- reactive({
  read_delim("/Users/d.murray/Documents/covid19-dimensions-analysis/data/derived/gender/authors_with_gender_covid-vaccine.tsv", delim = "\t")
})


#
# PLOT BUILDERS
# 
generate_gender_funding_plot <- function(table, selId) {
  table %>%
    filter(selId == "All" | country == selId) %>%
    group_by(id) %>% # split shared grants evenly across investigators
    mutate(amount = funding_usd / n()) %>%
    group_by(Gender)  %>% # Calculate gender-level variables
    summarize(
      amount = sum(amount),
      n = length(unique(id)),
      timespan = mean(num_years)
    ) %>%
    #group_by(country) %>%
    ungroup() %>%
    mutate(prop = amount / sum(amount) * 100,
           amount_per = amount / n,
           total = sum(amount)) %>%
    pivot_longer(cols = c(n, prop, amount_per), names_to = "metric") %>%
    mutate(metric = factor(metric, 
                           levels = c("n", "prop", "amount_per"),
                           labels = c("# Grants", "% Total Support", "$ Per Grant")
    ),
    Gender = factor(Gender, 
                    levels = c("f", "m", "UNK"),
                    labels = c("Women", "Men", "Unknown"))
    ) %>%
    ggplot(aes(x = Gender, y = value, fill = Gender)) +
    geom_col(color = "black") + 
    facet_wrap(~metric, scale = "free_y") +
    scale_fill_manual(values = c("darkorange", "dodgerblue4", "grey")) +
    theme_minimal() +
    theme(
      text = element_text(size = 14),
      panel.background = element_rect(size = 0.25, color = 'black', fill = NA),
      axis.title.y = element_blank(),
      legend.position = "none"
    )
}