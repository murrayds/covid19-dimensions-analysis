#
# dimreduce_with_umap.py
#
# author: dakota.s.murray@gmail.com
#
# Reduces the dimensions of a vector representation using UMAP
#
from gensim.models import Word2Vec
import pandas as pd
import umap


# The number of components to reduce to
N_COMPONENTS = 2
AXIS1_COLUMN_NAME = 'axis1'
AXIS2_COLUMN_NAME = 'axis2'
TOKEN_COLUMN_NAME = 'concept'

# Load the word2vec model
model = Word2Vec.load(snakemake.input[0])

# Build lists for the vectors and their labels
vectors = [model[word] for word in model.wv.vocab]
tokens = [word for word in model.wv.vocab]

# Setup the UMAP reducer
reducer = umap.UMAP(metric = "cosine",
                    n_neighbors = 20,
                    min_dist = 0.1,
                    n_components = N_COMPONENTS
                    )
umap_embedding = reducer.fit_transform(vectors)

# Convert to pandas dataframe and assign axis names
umap_coords_df = pd.DataFrame(umap_embedding, columns = [AXIS1_COLUMN_NAME, AXIS2_COLUMN_NAME])

# Add the token (word) as a column, labelling each coordinate
umap_coords_df[TOKEN_COLUMN_NAME] = tokens

# Save the output
umap_coords_df.to_csv(snakemake.output[0], sep = "\t", index = False)
