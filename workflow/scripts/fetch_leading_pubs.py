#
# fetch_leading_pubs.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return the
# the top COVID-19 publications
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

# BigQuery SQL for fetching leading organizations
bqsql = """
select
    doi,
    title.preferred as pub_title,
    journal.title as journal_title,
    year,
    volume,
    issue,
    pages,
    altmetrics.score as altmetrics,
    metrics.times_cited as citations,
    metrics.field_citation_ratio
  from `covid-19-dimensions-ai.data.publications`
  where type = "article"
  {condition}
  order by {metric} DESC
  limit 5;
"""

# Setup the filtering condition, first the general COVID topic filter
condition = covid_filter_bqsql

# Then, if specified, add the extra vaccine filter
if "covid-vaccine" in snakemake.output[0]:
    condition = covid_filter_bqsql + "\n" + vaccine_filter_bqsql

# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql.format(condition = condition,
                                      metric = snakemake.params[0]),
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False, sep = "\t")
