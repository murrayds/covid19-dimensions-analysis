#
# fetch_pub_concepts.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return the
# concepts associated with COVID-19 publications
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
SELECT
    id,
    ANY_VALUE(year) as year, -- get the year so that we can position these over time
    STRING_AGG(c.concept, ',') AS concepts -- so we unnest and aggregate, getting rid of the ectra "relevance" tag and other structure info that will add to the download
  FROM `covid-19-dimensions-ai.data.publications`,
  UNNEST(concepts) c
  WHERE type = "article"
  {condition}
  GROUP BY id;
"""

# Setup the filtering condition, first the general COVID topic filter
condition = covid_filter_concepts_bqsql

# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql.format(condition = condition),
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False, sep = "\t")
