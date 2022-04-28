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
  base.*,
  orgs.name,
  orgs.types,
  orgs.address.country,
  orgs.address.city,
  orgs_child.name AS child_org_name
  FROM ( -- Build sub0table containing grant-level information
    SELECT
      grant_id,
      grants.funder_org,
      grants.title,
      grants.funder_org AS child_org,
      CASE WHEN hierarchy.parent_id IS NULL THEN grants.funder_org ELSE hierarchy.parent_id END as org_id,
      grants.funding_amount
    FROM `covid-19-dimensions-ai.data.publications` AS pubs
    CROSS JOIN unnest(supporting_grant_ids) AS grant_id
    LEFT JOIN `covid-19-dimensions-ai.data.grants` AS grants on grants.id = grant_id
    LEFT JOIN (
      -- get the organizations
      SELECT
        g.id as child_id,
        children.id as parent_id
      FROM
        `covid-19-dimensions-ai.data.grid` g
      CROSS JOIN
        UNNEST(relationships) AS children
      WHERE children.type = "Parent"
    ) as hierarchy on hierarchy.child_id = grants.funder_org
    -- Filter to selected topics
    WHERE pubs.type = "article"
    AND funder_org IS NOT NULL
    {condition}
) AS base -- Now we merge organizational-level information
LEFT JOIN `covid-19-dimensions-ai.data.grid` AS orgs on orgs.id = org_id
LEFT JOIN `covid-19-dimensions-ai.data.grid` AS orgs_child on orgs_child.id = child_org
WHERE orgs.name IS NOT NULL AND funder_org IS NOT NULL;
"""

# Setup the filtering condition, first the general COVID topic filter
#
# Here, we need to format the text, since this query requires that we explicitely
# name the table containing the associated fields
#
condition = (covid_filter_bqsql
            .replace("concepts.concept", "pubs.concepts.concept")
            .replace("title.preferred", "pubs.title.preferred"))

condition_vax = (vaccine_filter_bqsql
                .replace("concepts.concept", "pubs.concepts.concept")
                .replace("title.preferred", "pubs.title.preferred"))

# Then, if specified, add the extra vaccine filter
if "covid-vaccine" in snakemake.output[0]:
    condition = condition + "\n" + condition_vax

# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql.format(condition = condition),
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False, sep = "\t")
