#
# build_projection_dataframe.R
#
# author: dakota.s.murray@gmail.com
#
# Plots the ready-made projection dataframe
#

library(ggplot2)
library(readr)

FIG_WIDTH = 5
FIG_HEIGHT = 4

# Read in the umap coordinates
coords <- read_delim(snakemake@input[[1]], delim = "\t")

plot <- ggplot(coords, aes(x = axis1, y = axis2, label = concept, fill = as.character(cls), size = (n))) +
  geom_point(shape = 21, color = "black", stroke = 0.2, alpha = 0.6) +
  scale_size_continuous(range = c(0.5, 8)) +
  scale_fill_brewer(palette = "Dark2") +
  theme_void() +
  theme(legend.position = "none")

ggsave(snakemake@output[[1]], plot, width = FIG_WIDTH, height = FIG_HEIGHT)
