#
# fetch_org_top_funders.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return the
# top publications associated with each organization
#

# TODO:
    # Add conditions to identify covid-specific grants
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

# BigQuery SQL for fetching top publications per org
bqsql = """
SELECT
  orgs.id as orgid,
  pubs.id as pubid,
  pubs.title,
  pubs.journal_title,
  pubs.times_cited,
FROM ( -- get publications associated with each organization
  SELECT
    id,
    title.preferred as title,
    journal.title as journal_title,
    orgid,
    metrics.times_cited,
    RANK() OVER (PARTITION BY orgid ORDER BY metrics.times_cited DESC) as rank
  FROM `covid-19-dimensions-ai.data.publications`,
  UNNEST(research_orgs) orgid
  WHERE type = "article"  -- limit to research articles
  {condition}
) as pubs
LEFT JOIN `covid-19-dimensions-ai.data.grid` AS orgs ON pubs.orgid = orgs.id
WHERE pubs.rank <= 5
ORDER BY orgs.id, times_cited desc;
"""

# Setup the filtering condition, first the general COVID topic filter
condition = covid_filter_bqsql

# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql.format(condition = condition),
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False, sep = "\t")
