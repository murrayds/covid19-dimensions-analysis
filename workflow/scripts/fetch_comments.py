#
# fetch_comments.py
#
# author: dakota.s.murray@gmail.com
#
# Queries the covid-19-dimensions-ai BigQuery database to return comments,
# corrections, and retractions based on title name
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
select
  ANY_VALUE(title.preferred) as pub_title,
  doi,
  ANY_VALUE(year) as year,
  ANY_VALUE(journal.title) as journal_title,
  ANY_VALUE(metrics.times_cited) as citations,
  STRING_AGG(c.concept, ";") as concepts
from `covid-19-dimensions-ai.data.publications`,
unnest(concepts) c
where regexp_contains(lower(title.preferred), "comment on|retraction|^correction")
and not regexp_contains(lower(title.preferred), "reply")
and type = "article"
group by doi
"""

# Save results to a dataframe
df = pandas_gbq.read_gbq(bqsql,
                         project_id=project_id)

# Save the dataframe returned by the query to the output file
df.to_csv(snakemake.output[0], index = False, sep = "\t")
