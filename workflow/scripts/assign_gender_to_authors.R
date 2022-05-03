#
# assign_gender_to_authors.R
#
# author: dakota.s.murray@gmail.com
#
# Plots the ready-made projection dataframe
#

library(dplyr)
library(readr)

authors <- read_delim(snakemake@input[[1]], delim = "\t")
gender <- read_csv(snakemake@input[[2]])


authors <- authors %>%
  left_join(gender, by = c("first_name" = "Name")) %>%
  mutate(
    Gender = tolower(Gender),
    Gender = ifelse(Gender %in% c("m", "f"), Gender, "UNK")
  )

write_delim(authors, snakemake@output[[1]], delim = "\t")
