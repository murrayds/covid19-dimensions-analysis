#
# Functions for working with the author table
#
# author: dakota.s.murray@gmail.com
#

#
# DATA GETTERS
#
concept.projection.table <- reactive({
  read_delim("data/derived/embedding/coords/concept_embedding_projection_df_50.tsv", delim = "\t")
})



#
# PLOT BUILDERS
#
generate_concept_projection <- function(metric) {
  ggplot(concept.projection.table() %>% rename(Metric = metric) %>% mutate(Metric = round(Metric, 3)),
       aes(x = axis1, y = axis2,
           label = concept, label2 = Metric,
           fill = as.character(cls),
           size = Metric)
  ) +
  geom_point(shape = 21, color = "black", stroke = 0.1, alpha = 0.6) +
  scale_size_continuous(range = c(0.5, 9)) +
  scale_fill_brewer(palette = "Dark2") +
  theme_void() +
  theme(legend.position = "none")
}
