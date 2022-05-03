#
# fetch_disagreement_sentence_counts.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return the
# concepts associated with COVID-19 publications
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

# BigQuery SQL for fetching publication concepts
bqsql = """
WITH matched_pubs AS (
  select
    dim.id as dim_id,
    s2orc.paper_id,
    dim.category_for.second_level.full as fields
  from `covid-19-dimensions-ai.data.publications` as dim
  inner join `ccnr-success.s2orc.pubs` as s2orc on lower(s2orc.doi) = lower(dim.doi)
  where s2orc.has_pdf_parse = True and dim.type = "article"
)

select
  field.name as field_name,
  SUM(disagreements) / SUM(total) as prop,
  COUNT(DISTINCT(dim_id)) as pub_count
FROM (
  SELECT
    dim_id,
    ANY_VALUE(fields) as fields,
    SUM(disagreement) as disagreements,
    COUNT(dim_id) as total
  FROM (
    SELECT
      m.dim_id,
      m.fields,
      CASE WHEN REGEXP_CONTAINS(lower(s.text), "no consensus|controversy|controversial|debate|debatable|debated") THEN 1 ELSE 0 END as disagreement,
    FROM `ccnr-success.s2orc.sentences` as s
    INNER JOIN matched_pubs as m on s.paper_id = m.paper_id
  )
  GROUP BY dim_id
),
unnest(fields) field
group by field.name
order by prop desc
"""

# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql,
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False, sep = "\t")
