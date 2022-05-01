#
# fetch_concept_frequency.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return the
# concept frequencies associated with each publication
#

import pandas_gbq
import tqdm

from query_chunks import *

import logging
logger = logging.getLogger('pandas_gbq')
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler())

# Project ID
project_id = "ccnr-success"

# BigQuery SQL for fetching publication concepts
bqsql = """
SELECT * FROM (
  SELECT
    concept.concept,
    pubs.year,
    COUNT(concept) as n,
  FROM `covid-19-dimensions-ai.data.publications` AS pubs,
  UNNEST(concepts) concept
  WHERE pubs.type = "article"
  {condition}
  GROUP BY concept, year
  ORDER BY n DESC
) WHERE n > 50
"""

# Setup the filtering condition, first the general COVID topic filter
condition = covid_filter_bqsql

# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql.format(condition = condition),
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False, sep = "\t")
