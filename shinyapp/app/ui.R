#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(shinycssloaders)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(
  navbarPage("Dimensions—COVID-19",
             #
             # About panel
             #
             tabPanel(
               "About",
               mainPanel(
                 h4("A dashboard for exploring the landscape, leaders, trends, and inequities of global COVID-19 and vaccine research"),
                 p("All analyses are based on the publicly-available",  a("database", href="https://www.dimensions.ai/covid19/"), " of COVID-19 publications published by Dimensions. This database consists of over 200 thousand publications relevant to COVID-19, of which over 18 thousand are related specifically to vaccines. A unique feature of Dimensions is its indexing of over 16 thousand grants
distributed by 241 funding organizations, making it possible to capture both the outputs and inputs of scientific research. This is a uniquely powerful database for understanding the landscape of COVID-19 science."),
                 p("This dashboard was created by",  a("Dakota Murray", href = "https://www.dakotamurray.me"), " using Shiny, a dashboard development tool based in R. The code used to create this dashboard, as well as an automated workflow for sourcing all data that underpins it using Google BigQuery, can be found in", a("this GitHub repository", href = "https://github.com/murrayds/covid19-dimensions-analysis")),
                 p("A thematic summary of findings generated from this dashboard can be found",  a("linked here.", href = "https://raw.githubusercontent.com/murrayds/covid19-dimensions-analysis/main/papers/scenario1_report.pdf")),
                 width = 6
               ) # End mainPanel
             ), # End tabPanel
             #
             # ORGANIZATION TABLE PANEL
             #
             tabPanel(
               "Leading organizations",
               mainPanel(
                 h4("Leading organizations pursuing COVID-19 and vaccine research"),
                 p("Around the world, research organizations have mobilized to respond to the ongoing COVID-19 crisis. These tables use data from", strong(em("Dimensions")), "to show which organizations lead the scientific response to COVID-19."),
                 p("By default, organizations are ranked by their total number of COVID-19 papers, but may also be sorted by the number and percentage of their papers that are in the top 10% of research measured by citations."),
                 p("Tabs allow you to also sort organizations by their contribution to", strong("All COVID-19 Research"), " (default), or specifically by", strong("COVID-19 Vaccine Research"), "."),
                 p("Selecting an organization will display additional information about it, including the leading authors pursuing COVID-19 research, the leading funders and funding amounts supporting COVID-19 research at the organization, and their most cited COVID-19 publications."),
                 column(7, align = "left",
                        fluidRow(column(tabsetPanel(
                          id = "org.tabSwitch",
                          tabPanel("All COVID-19 Research", DT::dataTableOutput("org.covid.all.table") %>% withSpinner(color="darkgrey")),
                          tabPanel("COVID-19 Vaccine Research", DT::dataTableOutput("org.covid.vaccine.table") %>% withSpinner(color="darkgrey"))
                        ),
                        width = 12)
                        )
                 ),
                 column(5,
                        verticalLayout(
                          h4("Top authors"),
                          fluidRow(column(align = "left", DT::dataTableOutput("org.top.authors") %>% withSpinner(color="darkgrey"), width = 12)),
                          h4("Top funders"),
                          fluidRow(column(align = "left", DT::dataTableOutput("org.top.funders") %>% withSpinner(color="darkgrey"), width = 12)),
                          h4("Top publications"),
                          fluidRow(column(align = "left", DT::dataTableOutput("org.top.pubs") %>% withSpinner(color="darkgrey"), width = 12))
                        )
                 ),
                 width = 12
              ) # End mainPanel
            ), # End tabPanel
            #
            # AUTHOR TABLE PANEL
            #
            tabPanel(
              "Leading authors",
              mainPanel(
                h4("Leading authors pursuing COVID-19 and vaccine research"),
                p("There are many ", strong(em("dimensions")), " that can be used to judge the most excellent researchers pusruing COVID-19 research. Their number of publications speaks to a researcher's productivity, whereas their total citations instead illustrates their impact. Some researchers may instead generate social impact measured through ", strong(em("altmetrics")), "."),
                p("These tables show the top 50 researchers pursuing COVID-19 and vaccine research around the world, measured by their publications, citations, and altmetrics score. Use the controls here to select the ranking metric to use and whether to highlight all COVID-19 researchers, or only those pursuing research into vaccines. Selecting a research will show the distribution of their publications across major fields of study, as well as their most over-represented topics, relative to their occurence across all COVID-19 papers."),
                radioButtons("author.metric", "Ranking metric:",
                             c("Publications" = "pubcount",
                               "Citations" = "citations",
                               "Altmetrics" = "altmetrics"
                             ),
                             inline = TRUE),
                column(7, align = "left",
                       fluidRow(column(tabsetPanel(
                         id = "author.tabSwitch",
                         tabPanel("All COVID-19 Research", DT::dataTableOutput("author.covid.all.table") %>% withSpinner(color="darkgrey")),
                         tabPanel("COVID-19 Vaccine Research", DT::dataTableOutput("author.covid.vaccine.table") %>% withSpinner(color="darkgrey")),
                        ),
                        width = 12)
                       )
                ), # End column
                column(5,
                       verticalLayout(
                         h4("Top Publications"),
                         fluidRow(column(align = "left",
                                         DT::dataTableOutput("author.top.pubs") %>% withSpinner(color="darkgrey"),
                                         width = 12),
                                  height = "50%") ,
                         fluidRow(
                           column(align = "left",
                                  h4("Field of publications"),
                                  plotOutput("author.fields") %>% withSpinner(color="darkgrey"),
                                  width = 8),
                           column(align = "left",
                                  h4("Keywords"),
                                  DT::dataTableOutput("author.keywords") %>% withSpinner(color="darkgrey"),
                                  width = 4),
                           height = "50%"
                           )
                       )
                ),
                width = 12
              ) # End mainPanel
            ), # End tabPanel
            #
            # PUBLICATION TABLE PANEL
            #
            tabPanel(
              "Leading publications",
              mainPanel(
                h4("Leading publications relevant to COVID-19 research"),
                p("The COVID-19 pandemic has brought with it a deluge of publications. Some of these publications have accumulated tremendous amounts of attention within science, social media, and policy. Here it is possible to identify the top COVID-19 and vaccine-related publications by their scientific (number of citations) and social impact (altmetrics score)."),
                radioButtons("pub.metric", "Ranking metric:",
                             c("Citations" = "citations",
                               "Altmetrics" = "altmetrics"
                             ),
                             inline = TRUE),
                column(12, align = "left",
                       fluidRow(column(tabsetPanel(
                         id = "pub.tabSwitch",
                         tabPanel("All COVID-19 Research", DT::dataTableOutput("pub.covid.all.table")),
                         tabPanel("COVID-19 Vaccine Research", DT::dataTableOutput("pub.covid.vaccine.table"))
                         ),
                       width = 12)
                       )
                ), # End column
                width = 12
              ) # End mainPanel
            ), # End tabPanel
            #
            # FUNDER TABLE PANEL
            #
            tabPanel(
              "Leading funders",
              mainPanel(
                h4("Leading funding organizations supporting COVID-19 research"),
                p("Research into COVID-19 and vaccines has received generous support thanks to the efforts of national and international funding organizations. Using data from ", strong(em("Dimensions")), " it is possible to identify the top funders and uncover their spending portfolios."),
                p("This table shows the top funders, their main country of operation, and ther total spending. Selecting a funder from this table will reveal their top recipents, as well as display a treemap illustrating how their spending is distributed across sectors and countires. Multi-instition grants are divided equally between the organizations."),
                column(7, align = "left",
                       fluidRow(column(tabsetPanel(
                         id = "funder.tabSwitch",
                         tabPanel("All COVID-19 Research", DT::dataTableOutput("funder.covid.all.table")),
                         tabPanel("COVID-19 Vaccine Research", DT::dataTableOutput("funder.covid.vaccine.table"))
                       ),
                       width = 12)
                       )
                ), # End column
                column(5,
                       verticalLayout(
                         h4("Top recipients"),
                         fluidRow(column(align = "left", DT::dataTableOutput("funder.recipients") %>% withSpinner(color="darkgrey"), width = 12)) ,
                         fluidRow(column(align = "left",
                                         h4("Recipient sectors"),
                                         plotOutput("funder.recipients.sectors") %>% withSpinner(color="darkgrey"), width = 6),
                                  column(align = "left",
                                         h4("Recipient countries"),
                                         plotOutput("funder.recipients.countries") %>% withSpinner(color="darkgrey"), width = 6))
                       ) # End verticalLayout
                ), # End column
                width = 12
              ) # End mainPanel
            ), # End tabPanel
            #
            # LANDSCAPE OF COVID-19 RESEARCH
            #
            tabPanel(
              "Landscape",
              mainPanel(
                h4("Topical landscape of COVID-19 research"),
                p("By drawing on advances in neural networks and machine learning, we can construct an ", strong(em("embedding")), " of the concepts extracted from COVID-19 publications. The embedding, created using ", em("word2vec"), " creates a vector representation of concepts, where the distance between concepts reflects their tendency to co-occur together on the same paper. The resulting vectors can then be projected into 2-dimensions using the technique UMAP, resulting in the figure below. Simple clustering using DBScan helps reveal the structure of the landscape of COVID-19 topics."),
                p("The size of points corresponds to either the number of papers published with that concpet, or the average number of citations or altmetrics score of papers containing the concept."),
                p("Exploring the concpet landscape below reveals major topical disatinctions in COVID-19 research, such as papers covering the biology of the virus to its social implications."),
                radioButtons("landscape.metric", "Size metric:",
                             c("Publications" = "n",
                               "Citations" = "avg_times_cited",
                               "Altmetrics" = "avg_altmetrics"
                             ),
                             inline = TRUE),
                fluidRow(plotlyOutput("concept.projection", height = "700px") %>% withSpinner(color="darkgrey"), width = 12) ,
                width = 12
              ) # End mainPanel
            ), # End tabPanel
            #
            # TRENDS IN COVID-19 RESEARCH
            #
            tabPanel(
              "Trends",
              sidebarLayout(
                sidebarPanel(
                          radioButtons("trends.topic", "Research topic:",
                               c("All COVID-19 Research" = "all",
                                 "COVID-19 Vaccine Research" = "vaccine")
                          ),
                          selectInput("trends.country", "Choose a country:",
                                         list(`Worldwide` = list("All"),
                                              `North America` = list("United States", "Canada", "Mexico"),
                                              `Europe` = list("Belgium", "Denmark", "France", "Germany","Italy",
                                                              "Netherlands", "Poland", "Portugal", "Spain",
                                                              "Russia", "Sweden", "Switzerland", "United Kingdom"),
                                              `Asia/Oceania` = list("Australia", "New Zealand", "China", "India", "Indonesia", "Japan", "South Korea"),
                                              `South America` = list("Brazil", "Peru", "Argentina", "Chile"),
                                              `Africa` = list("Egypt", "Kenya", "Nigeria", "South Africa", "Zimbabwe"))
                            ), width = 2
                ), # END sidebarPanel
                mainPanel(
                  h4("Temporal changes in COVID-19 research"),
                  p("The rate and topical distribution of COVID-19 research has evovled over time and is different across countires. Using this dashboard, it is possible to expore how many publications a country produced across each quarter throughout the pandemic, as well as the distribution of publications across topic categories"),
                  column(align = "left",
                         width = 12,
                         fluidRow(plotlyOutput("trends.country.absolute") %>% withSpinner(color="darkgrey"), width = 12),
                         fluidRow(plotlyOutput("trends.country.relative") %>% withSpinner(color="darkgrey"), width = 12)
                  ) # END column
                )
              ) # End sidebarLayout
            ), # End tabPanel
            #
            # TRENDS IN COVID-19 RESEARCH
            #
            tabPanel(
              "Gender in funding",
              sidebarLayout(
                sidebarPanel(
                  radioButtons("gender.topic", "Research topic:",
                               c("All COVID-19 Research" = "all",
                                 "COVID-19 Vaccine Research" = "vaccine")
                  ),
                  selectInput("gender.country", "Choose a country:",
                              list(`Worldwide` = list("All"),
                                   `North America` = list("United States", "Canada"),
                                   `Europe` = list("Belgium", "Denmark", "France", "Italy",
                                                   "Netherlands", "Portugal",
                                                   "Sweden", "Switzerland", "United Kingdom"),
                                   `Asia/Oceania` = list("Australia", "New Zealand", "China", "India", "Japan")
                              )
                  ), # END selectInput
                  width = 2
                ), # END sidebarPanel
                mainPanel(
                  h4("Inequities in funding support for men and women by country"),
                  p("Diveristy in science is not only a matter of justice, but also empowers research with different persepctives and approaches. Historically, women have been excluded from scientific institutions. Despite recent progress, there remain pressing inequities in women's access to resources for science."),
                  p("This panel shows the distribution of fuding support betwee men and women by country, and between all COVID-19 and vaccine-specific research."),
                  p("Gender is assigned based on the first name of the investigators associated with each grant indexed in ", strong(em("Dimensions")), " and all amounts are displayed in U.S. dollars. Multiple countries have been excluded for lack of data."),
                  column(align = "left",
                         width = 12,
                         fluidRow(plotOutput("gender.country.plot") %>% withSpinner(color="darkgrey"), width = 12)
                  ) # END column
                ) # END mainPanel
            ) # End sidebarLayout
        ), # END tabPanel
        #
        # UNCERTAINTY TABLE PANEL
        #
        tabPanel(
          "Uncertainty",
          mainPanel(
            h4("Disagreements, corrections, and retractions in COVID-19 research"),
            p('Uncertainty is uniquitious, normal, and even healthy for science. Yet in a pandemic where policy and praxis draw heavily on cutting-edge research, disagreements must be raised and resolved with more speed than usual. Knowing what disagreements and sources of uncertainty exist and what they are about can be useful for identifying which projects to fund, especially if a goal of funding is to promote actionable scientific consensus.'),
            p("Here, published comments, corrections, and criticisms are identified from among all COVID-19 research, and arranged by the total citations they receive. Note that these are not citations to the original paper, but instead to the correction."),
            p("Over 2,000 in-text disagreements are also matched between Dimensions and S2ORC—a database of structured scientific full-text data—based on DOI matching. In-text disagreements in these papers are identified based on key words, and used to quantify the rate of disagreement across fields."),
            column(align = "left",
                   fluidRow(DT::dataTableOutput("uncertainty.covid.all.table")),
                   width = 8),
            column(align = "left",
                   fluidRow(plotOutput("uncertainty.plot") %>% withSpinner(color="darkgrey")),
                   width = 4),
            width = 12
            ) # mainPanel
            
        ) # End tabPanel
  ) # End navbarPage
)
