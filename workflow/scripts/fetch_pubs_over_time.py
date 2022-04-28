#
# fetch_pubs_over_time.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return the
# publications over time
#
# Included are conditions filtering to COVID, or COVID-Vacine research,
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

# BigQuery SQL for fetching leading publications
bqsql = """
SELECT
  ARRAY_CONCAT_AGG(pubs.research_org_countries) AS countries,
  ARRAY_CONCAT_AGG(pubs.research_org_state_codes) AS states,
  ANY_VALUE(DATE_TRUNC(SAFE_CAST(pubs.date_online AS DATE), MONTH)) as published_date,
  STRING_AGG(c.name, ",") AS fields,
  ANY_VALUE(journal.title) AS journal_title, -- the title of the journal
  ANY_VALUE(metrics.times_cited) AS times_cited,
  ANY_VALUE(altmetrics.score) AS altmetrics_score
  FROM `covid-19-dimensions-ai.data.publications` AS pubs,
  UNNEST(category_for.second_level.full) c
  WHERE pubs.type = "article"
  {condition}
  GROUP BY (pubs.id)
"""

# Setup the filtering condition, first the general COVID topic filter
condition = covid_filter_bqsql

# Then, if specified, add the extra vaccine filter
if "covid-vaccine" in snakemake.output[0]:
    condition = covid_filter_bqsql + "\n" + vaccine_filter_bqsql

# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql.format(condition = condition),
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False, sep = "\t")
