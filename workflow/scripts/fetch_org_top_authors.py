#
# fetch_org_top_authors.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return the
# top authors affiliated with each orgainzations
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

# BigQuery SQL for fetching top authors per org
bqsql = """
SELECT * EXCEPT(rank) FROM (
SELECT
  top.*,
  RANK() OVER (PARTITION BY top.orgid ORDER BY top.citations DESC) as rank
  FROM (
    SELECT
      orgid,
      ANY_VALUE(auth.first_name) as first_name,
      ANY_VALUE(auth.last_name) as last_name,
      SUM(metrics.times_cited) as citations,
      COUNT(id) as pubcount,
    FROM `covid-19-dimensions-ai.data.publications`,
    UNNEST(authors) auth, UNNEST(auth.grid_ids) orgid
    WHERE type = "article"  -- limit to research articles
    {condition}
    AND researcher_id is not null
    group by researcher_id, orgid
    order by citations desc
  ) AS top
) WHERE rank <= 5;
"""

# Setup the filtering condition, first the general COVID topic filter
condition = covid_filter_bqsql

# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql.format(condition=condition),
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False, sep = "\t")
