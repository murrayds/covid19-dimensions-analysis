#
# fetch_funding_investigators.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return the
# grants and their associated investigators
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

# BigQuery SQL for fetching funding organizations
bqsql = """
SELECT
  grants.id,
  LOWER(pi.first_name) as first_name,
  ARRAY_LENGTH(active_years) as num_years,
  pi.researcher_id,
  grid.name,
  grid.address.country,
  funding_usd
FROM `covid-19-dimensions-ai.data.grants` as grants,
unnest(investigators) pi
LEFT JOIN `covid-19-dimensions-ai.data.grid` as grid on grid.id = grants.funder_org
where pi.first_name is not null and funding_amount is not null;
"""

# Setup the filtering condition, first the general COVID topic filter
#
# Here, we need to format the text, since this query requires that we explicitely
# name the table containing the associated fields
#
condition = covid_filter_bqsql

# Then, if specified, add the extra vaccine filter
if "covid-vaccine" in snakemake.output[0]:
    condition = condition + "\n" + vaccine_filter_bqsql


# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql.format(condition = condition),
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False, sep = "\t")
