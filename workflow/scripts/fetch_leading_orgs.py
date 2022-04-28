#
# fetch_leading_orgs.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return the
# the leading organizations pursuing COVID-19 research
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
  counts.id,
  counts.pubcount as pub_count,
  orgs.name,
  orgs.address.country as country,
  orgs.address.latitude as latitude,
  orgs.address.longitude as longitude
from
(
  select
    orgs.id,
    count(orgs.id) as pubcount
  from (
    SELECT id, orgid
    FROM `covid-19-dimensions-ai.data.publications`,
    UNNEST(research_orgs) orgid
    WHERE type = "article"  -- limit to research articles
    {condition} -- This is where we insert a condition
  ) as pubs
  left join `covid-19-dimensions-ai.data.grid` as orgs on pubs.orgid = orgs.id
  group by orgs.id
) as counts
left join `covid-19-dimensions-ai.data.grid` as orgs on counts.id = orgs.id
order by pub_count DESC
"""

# Setup the filtering condition, first the general COVID topic filter
condition = covid_filter_bqsql

# Then, if specified, add the extra vaccine filter
if "covid-vaccine" in snakemake.output[0]:
    condition = covid_filter_bqsql + "\n" + vaccine_filter_bqsql

# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql.format(condition=condition),
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False)
