#
# fetch_org_top_funders.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return the
# organizations that provide the most funding
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

# BigQuery SQL for fetching top authors per org
bqsql = """
SELECT orgid, funder_name, amount FROM (
  SELECT
    amounts.*,
    funders.name as funder_name,
    RANK() OVER(PARTITION BY orgid ORDER BY amount DESC) as rank
  FROM (
    SELECT
      grants.funder_org,
      orgid,
      SUM(grants.funding_amount) as amount,
    FROM `covid-19-dimensions-ai.data.grants` as grants,
    UNNEST(research_orgs) orgid
    GROUP BY funder_org, orgid
  ) as amounts
  LEFT JOIN `covid-19-dimensions-ai.data.grid` as funders on funders.id = amounts.funder_org
  WHERE funders.name IS NOT NULL
  ORDER BY orgid, amount DESC
);
"""

# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql,
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False, sep = "\t")
