#
# Functions for working with the funder-table
#
# author: dakota.s.murray@gmail.com
#

library(treemapify)

#
# HARD-CODED FACTOR LEVELS
#
sector_levels = c("Education", "Healthcare", "Government", "Facility", "Nonprofit", "Company", "Other")
sector_colors = c("Education" = "#00bfa0",
                  "Healthcare" = "#e60049",
                  "Government" = "#0bb4ff",
                  "Facility" = "#50e991",
                  "Nonprofit" = "#e6d800",
                  "Company" = "#ffa300",
                  "Other" = "grey")

country_levels = c("United States", "United Kingdom", "Canada", "China", "Germany", "Japan", "France", "Switzerland", "Sweden", "Other")

country_colors = c("United States" = "#fd7f6f",
                  "United Kingdom" = "#7eb0d5",
                  "Canada" = "#b2e061",
                  "China" = "#bd7ebe",
                  "Germany" = "#ffb55a",
                  "Japan" = "#ffee65",
                  "France" = "#beb9db",
                  "Switzerland" = "#fdcce5",
                  "Sweden" = "#8bd3c7",
                  "Other" = "grey")
#
# DATA GETTERS
#
get_funder_table_agg <- function(topic) {
  get_funder_table(topic) %>%
    group_by(funder_org, funder_name) %>%
    summarize(num_grants = n(),
              amount = sum(amount, na.rm = T),
              country = first(country)
    ) %>%
    arrange(desc(amount)) %>%
    filter(amount > 0) %>%
    ungroup()
}

get_funder_table <- function(topic) {
  read_delim(paste0("../../data/bq-data/funding_orgs/funding_orgs_covid-",
                    topic,
                    ".tsv"),
             delim = "\t")
}


get_recipient_table <- function(topic) {
  read_delim(paste0("../../data/bq-data/funding_orgs/funding_recipients_covid-",
                    topic,
                    ".tsv"),
             delim = "\t")
}


#
# TABLE BUILDERS
#
generate_funder_table <- function(table) {
  table %>%
    select(funder_name, country, num_grants, amount) %>%
    mutate(amount = prettyNum(amount, big.mark=",")) %>%
    rename(
      Name = funder_name,
      Country = country,
      `# Grants` = num_grants,
      `Funding` = amount
    )
}

genrate_funder_top_grants_table <- function(table, selId) {
  table %>%
    filter(selId == funder_org) %>%
    select(title, amount) %>%
    arrange(desc(amount)) %>%
    top_n(5, amount) %>%
    mutate(amount = prettyNum(amount, big.mark=",")) %>%
    rename(
      Title = title,
      `Funding` = amount
    )
}

#
# PLOT BUILDERS
#
genrate_funder_recipient_table <- function(table, selId) {
  table %>%
    filter(selId == funder_org) %>%
    filter(!is.na(amount)) %>%
    group_by(id) %>%
    mutate(amount = amount / n()) %>%
    group_by(recipient_name) %>%
    summarize(amount = sum(amount, na.rm = T),
              country = first(country)
    ) %>%
    arrange(desc(amount)) %>%
    top_n(5, amount) %>%
    ungroup() %>%
    mutate(amount = prettyNum(amount, big.mark=",")) %>%
    select(recipient_name, country, amount) %>%
    rename(
      Recipient = recipient_name,
      Country = country,
      `Funding` = amount
    )
}

# Bulds a treemap of funding by sector of recipient
generate_sector_treemap <- function(selId, topic) {
  get_recipient_table(topic) %>%
    filter(funder_org == selId) %>%
    mutate(sector = trimws(gsub("\\[|\\]|\\'", "", recipient_types))) %>%
    group_by(id) %>% # divide amounts split among orgs
    mutate(
      amount = amount / sum(amount),
    ) %>%
    ungroup() %>%
    mutate(total = sum(amount)) %>% # calculate the total across all grants
    group_by(sector) %>%
    summarize(
      n = n(),
      prop = sum(amount) / first(total)
    ) %>%
    mutate(sector = factor(sector, levels = sector_levels)) %>%
    mutate(label = paste0(sector, "\n", round(prop, 3) * 100, "%")) %>%
    ggplot(aes(area = prop, fill = sector, label = label)) +
    geom_treemap(color = "black") +
    geom_treemap_text(colour = "white",
                      place = "centre",
                      grow = TRUE) +
    theme_void() +
    scale_fill_manual(values = sector_colors) +
    theme(legend.position = "none")
}

# Bulds a treemap of funding by country of recipient
generate_country_treemap <- function(selId, topic) {
  get_recipient_table(topic) %>%
    filter(funder_org == selId) %>%
    mutate(country = ifelse(country %in% country_levels, country, "Other")) %>%
    group_by(id) %>% # divide amounts split among orgs
    mutate(
      amount = amount / sum(amount),
    ) %>%
    ungroup() %>%
    mutate(total = sum(amount)) %>% # calculate the total across all grants
    group_by(country) %>%
    summarize(
      n = n(),
      prop = sum(amount) / first(total)
    ) %>%
    mutate(sector = factor(country, levels = country_levels)) %>%
    mutate(label = paste0(country, "\n", round(prop, 3) * 100, "%")) %>%
    ggplot(aes(area = prop, fill = sector, label = label)) +
    geom_treemap(color = "black") +
    geom_treemap_text(colour = "black",
                      place = "centre",
                      grow = TRUE) +
    theme_void() +
    scale_fill_manual(values = country_colors) +
    theme(legend.position = "none")
}
