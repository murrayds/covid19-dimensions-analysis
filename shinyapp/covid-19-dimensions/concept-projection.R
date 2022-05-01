#
# Functions for working with the author table
#
# author: dakota.s.murray@gmail.com
#

#
# DATA GETTERS
#
concept.projection.table <- reactive({
  read_delim("/Users/d.murray/Documents/covid19-dimensions-analysis/data/derived/embedding/coords/concept_embedding_projection_df_50.tsv", delim = "\t")
})



#
# PLOT BUILDERS
#
generate_concept_projection <- function() {
  ggplot(concept.projection.table(), 
       aes(x = axis1, y = axis2, 
           label = concept, 
           fill = as.character(cls), 
           size = n)
  ) +
  geom_point(shape = 21, color = "black", stroke = 0.1, alpha = 0.6) +
  scale_size_continuous(range = c(0.75, 10)) +
  scale_fill_brewer(palette = "Dark2") +
  theme_void() +
  theme(legend.position = "none")
}