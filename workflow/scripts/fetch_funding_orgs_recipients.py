#
# fetch_funding_orgs.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return the
# organizations funding COVID-19 research
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
  grants.funder_org,
  title,
  recipients.name as recipient_name,
  recipients.address.country,
  recipients.types as recipient_types,
  funding_usd as amount,
FROM `covid-19-dimensions-ai.data.grants` as grants,
UNNEST(research_orgs) orgid
LEFT JOIN `covid-19-dimensions-ai.data.grid` as recipients on recipients.id = orgid
WHERE recipients.name IS NOT NULL AND funding_usd IS NOT NULL
{condition}
ORDER BY funder_org, amount, recipient_name;
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

condition = condition.replace("title.preferred", "title")

# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql.format(condition = condition),
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False, sep = "\t")
