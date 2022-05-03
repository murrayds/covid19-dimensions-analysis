#
# build_projection_dataframe.R
#
# author: dakota.s.murray@gmail.com
#
# Aggregates files related to the UMAP projection of the embedding space into
# a single file, ready for visualization
#

library(dplyr)
library(readr)
library(dbscan)

# Set a random seed, just to allow for reproduction in the future
set.seed(1234)

# Read in the umap coordinates
coords <- read_delim(snakemake@input[[1]], delim = "\t")

# Next, read in the frequencies of concepts across the Dimensions database
freq <- read_delim(snakemake@input[[2]], delim = "\t")

# Identify clusters of the data.
#
# This is mostly as a visual aid and so I'm not too concerned about the accuracy,
# so just running an easy dbscan should work fine
cls <- dbscan(coords %>% select(axis1, axis2), eps = 0.45, MinPts = 110)
coords$cls <- as.character(cls$cluster)

# Now construct the final dataframe
coords.formatted <- coords %>%
  left_join(freq, by = c("concept")) %>%
  filter(n > 10) %>%
  mutate(
    n = n / max(n, na.rm = T)
  )

write_delim(coords.formatted, snakemake@output[[1]], delim = "\t")
