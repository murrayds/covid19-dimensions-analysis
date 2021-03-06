#
# fetch_leading_authors.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return the
# the leading authors pursuing COVID-19 research
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

# BigQuery SQL for fetching leading authors
bqsql = """
WITH top_researchers AS (
  SELECT * FROM (
      SELECT
        auth.researcher_id,
        ANY_VALUE(auth.first_name) AS first_name,
        ANY_VALUE(auth.last_name) AS last_name,
        COUNT(DISTINCT(pubs.id)) AS pubcount,
        SUM(altmetrics.score) AS altmetrics,
        SUM(metrics.times_cited) AS citations,
      FROM `covid-19-dimensions-ai.data.publications` AS pubs,
      UNNEST(authors) auth
      WHERE type = "article" AND researcher_id IS NOT NULL
      {condition}
      GROUP BY researcher_id
      ORDER BY {metric} DESC
    )
    WHERE pubcount > 4 -- keep only productive authors, no single-paper wonders
    LIMIT 50
),
researcher_orgs AS (
  -- Get the most frequent affiliation of the researcher
  SELECT researchers.*, orgs.name AS org_name, orgs.address.country AS org_country, orgs.address.city AS org_city
  from (
    SELECT top.researcher_id, org_id, COUNT(DISTINCT(p.id)) AS org_count
    FROM `covid-19-dimensions-ai.data.publications` AS p
    INNER JOIN top_researchers AS top ON top.researcher_id IN UNNEST(p.authors.researcher_id)
    CROSS JOIN UNNEST(p.authors) auth,
    UNNEST(auth.grid_ids) AS org_id
    WHERE TRUE
    GROUP BY top.researcher_id, org_id
    QUALIFY ROW_NUMBER() OVER (PARTITION BY top.researcher_id ORDER BY org_count DESC) = 1
  ) AS researchers
  LEFT JOIN `covid-19-dimensions-ai.data.grid` AS orgs ON orgs.id = researchers.org_id
),
researcher_concepts AS (
  -- Get the concepts associated with papers they published
  SELECT top.researcher_id, STRING_AGG(c.concept, ";") AS concepts
  FROM `covid-19-dimensions-ai.data.publications` AS p,
  UNNEST(concepts) c
  INNER JOIN top_researchers AS top ON top.researcher_id IN UNNEST(p.authors.researcher_id)
  GROUP BY top.researcher_id
),
researcher_fields AS (
  -- get all the fields the researcher published in
  SELECT
  top.researcher_id,
  STRING_AGG(for2.name, ";") as fields,
  FROM `covid-19-dimensions-ai.data.publications` AS p
  INNER JOIN top_researchers AS top ON top.researcher_id IN UNNEST(p.authors.researcher_id)
  CROSS JOIN UNNEST(category_for.first_level.full) AS for2
  WHERE TRUE
  GROUP BY top.researcher_id
),
researcher_pubs AS (
  SELECT
    researcher_id,
    STRING_AGG(title, ";") as titles,
    STRING_AGG(journal_title, ";") as journal_titles,
    ARRAY_AGG(citations) as citations
    FROM (
        SELECT
          top.researcher_id,
          pubs.title.preferred as title,
          pubs.journal.title as journal_title,
          pubs.metrics.times_cited as citations,
          RANK() OVER(PARTITION BY researcher_id ORDER BY metrics.times_cited DESC) rank
        FROM `covid-19-dimensions-ai.data.publications` as pubs,
        UNNEST(researcher_ids) researcher
        INNER JOIN top_researchers AS top on top.researcher_id = researcher
        ORDER BY researcher_id, rank DESC
      )
    WHERE rank <= 5
    GROUP BY researcher_id
)

-- Now, select from out temporary tables defined above
SELECT
  top.*,
  fields.* except(researcher_id),
  concepts.* except(researcher_id),
  orgs.* except(org_count, researcher_id),
  pubs.* except(researcher_id)
FROM top_researchers AS top
LEFT JOIN researcher_fields AS fields on fields.researcher_id = top.researcher_id
LEFT JOIN researcher_concepts AS concepts on concepts.researcher_id = top.researcher_id
LEFT JOIN researcher_orgs AS orgs ON orgs.researcher_id = top.researcher_id
LEFT JOIN researcher_pubs AS pubs ON pubs.researcher_id = top.researcher_id
ORDER BY top.{metric} DESC
"""

# Setup the filtering condition, first the general COVID topic filter
condition = covid_filter_bqsql

# Then, if specified, add the extra vaccine filter
if "covid-vaccine" in snakemake.output[0]:
    condition = covid_filter_bqsql + "\n" + vaccine_filter_bqsql

print(bqsql.format(condition = condition,
                                      metric = snakemake.params[0]))
# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql.format(condition = condition,
                                      metric = snakemake.params[0]),
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False, sep = "\t")
