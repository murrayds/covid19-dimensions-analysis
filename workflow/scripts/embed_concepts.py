#
# embed_concepts.py
#
# author: dakota.s.murray@gmail.com
#
# Uses gensim's word2vec to learn an embedding of concepts by
# treating each paper's set of concepts as a set of "words"
#
import gensim
import pandas as pd
import random

# Set up the logging so that we can see progress
import logging
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)


# Load all of the the data to use in the embedding
logging.info("Loading mobility trajectories")

df = pd.read_csv(snakemake.input[0], sep = "\t")

# Tokenize the sentences into a format that gensim can work with
logging.info("Building initial vocabulary")

tokens = []
for sentence in df.concepts:
    tokens.append(sentence.split(','))

# Build and train the gensim word2vec model.
# First, perform initial training on unshuffled vocabulary
model = gensim.models.Word2Vec(
            tokens,
            size = int(snakemake.params[0]),
            window = 10, # just use the entire sentence
            min_count = 3, # Remove tokens that don't appear enough
            workers = 4, # paralellize, use 4 workers
            iter = 5,
            sg = 1 # use the skip_gram model
) # end model

# Save the model
model.save(snakemake.output[0])
