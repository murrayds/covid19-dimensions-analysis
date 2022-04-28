#
# query_chunks.py
#
# author: dakota.s.murray@gmail.com
#
# Contains the parts of queries used throughout the project
#

###
#
# Query chunks
#
###
covid_filter_bqsql = """
AND ('COVID-19' in UNNEST(concepts.concept) or "new coronavirus" in UNNEST(concepts.concept) or "SARS-CoV-2" in UNNEST(concepts.concept)
      OR 'ncov' in UNNEST(concepts.concept) or "novel coronavirus" in UNNEST(concepts.concept) or "2019-ncov" in UNNEST(concepts.concept)
      OR "severe acute respiratory syndrome coronavirus" in UNNEST(concepts.concept) or 'coronavirus disease 2019' in UNNEST(concepts.concept)
      OR REGEXP_CONTAINS(title.preferred, r"covid-19|new coronavirus|novel coronavirus|sars-cov-2|2019-ncov|hcov|severe acute respiratory syndrome coronavirus|coronavirus disease 2019"))
"""

covid_filter_named_bqsql = """
AND ('COVID-19' in UNNEST(pubs.concepts.concept) or "new coronavirus" in UNNEST(pubs.concepts.concept) or "SARS-CoV-2" in UNNEST(pubs.concepts.concept)
      OR 'ncov' in UNNEST(pubs.concepts.concept) or "novel coronavirus" in UNNEST(pubs.concepts.concept) or "2019-ncov" in UNNEST(pubs.concepts.concept)
      OR "severe acute respiratory syndrome coronavirus" in UNNEST(pubs.concepts.concept) or 'coronavirus disease 2019' in UNNEST(pubs.concepts.concept)
      OR REGEXP_CONTAINS(title.preferred, r"covid-19|new coronavirus|novel coronavirus|sars-cov-2|2019-ncov|hcov|severe acute respiratory syndrome coronavirus|coronavirus disease 2019"))
"""

covid_filter_concepts_bqsql = """
AND (LOWER(c.concept) IN UNNEST(["covid-19", "new coronavirus", "novel coronavirus", "sars-cov-2", "2019-ncov", "hcov", "hcov-2019", "severe acute respiratory syndrome coronavirus 2", "coronavirus disease 2019"])
    OR REGEXP_CONTAINS(title.preferred, r"covid-19|new coronavirus|novel coronavirus|sars-cov-2|2019-ncov|hcov|severe acute respiratory syndrome coronavirus|coronavirus disease 2019"))
"""

vaccine_filter_bqsql = """
AND ('vaccine' in UNNEST(concepts.concept) or 'vaccination' in UNNEST(concepts.concept) or 'mRNA' in UNNEST(concepts.concept)
         OR REGEXP_CONTAINS(title.preferred, r"vaccine|vaccination|mrna"))
"""

vaccine_filter_named_bqsql = """
AND ('vaccine' in UNNEST(pubs.concepts.concept) or 'vaccination' in UNNEST(pubs.concepts.concept) or 'mRNA' in UNNEST(pubs.concepts.concept)
         OR REGEXP_CONTAINS(pubs.title.preferred, r"vaccine|vaccination|mrna"))
"""
