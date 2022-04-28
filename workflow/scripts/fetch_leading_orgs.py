#
# fetch_leading_orgs.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return the
# the leading organizations pursuing COVID-19 research
#
# Included are conditions filtering to COVID, or COVID-Vacine research, as
# well as ranking authors by publications, citations, or altmetrics
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
SELECT
  counts.id,
  counts.pubcount,
  counts.top_10_percent,
  ROUND(counts.top_10_percent / pubcount, 3) AS top_10_percent_prop,
  orgs.name,
  orgs.address.country AS country,
  orgs.address.latitude AS latitude,
  orgs.address.longitude AS longitude
FROM
(
  SELECT
    orgs.id,
    COUNT(orgs.id) as pubcount,
    SUM(CASE WHEN citation_percentile < 0.1 THEN 1 ELSE 0 END) as top_10_percent
  FROM (
    SELECT id, orgid, PERCENT_RANK() OVER (ORDER BY metrics.times_cited DESC) citation_percentile
    FROM `covid-19-dimensions-ai.data.publications`,
    UNNEST(research_orgs) orgid
    WHERE type = "article"  -- limit to research articles
    {condition}
  ) as pubs
  LEFT JOIN `covid-19-dimensions-ai.data.grid` AS orgs ON pubs.orgid = orgs.id
  GROUP BY orgs.id
) as counts
LEFT JOIN `covid-19-dimensions-ai.data.grid` AS orgs ON counts.id = orgs.id
WHERE pubcount > 100
ORDER BY pubcount DESC
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
df.to_csv(snakemake.output[0], index = False, sep = "\t")
