# covid19-dimensions-analysis

An example workflow and interactive dashboard built on top of the Dimensions COVID-19 open database. Data is sourced from the BigQuery version of this data, and the dashboard is built in R's Shiny. 

The data workflow is built using `snakemake`—a python-based automation tool. To use this tool, you will need snakemake installed in your local environment. To run the workflow, you will also need `gsutil` and to be logged into the ccnr-success project. Once these requirements are satisfied, navigate to the `workflow/` directory, and run the command `snakemake -j 1 --use-conda`, and all the data *should* be quieried and processed automatically. 
