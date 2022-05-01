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
  navbarPage("COVID-19 Research", 
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
                          tabPanel("All COVID-19 Research", DT::dataTableOutput("org.covid.all.table")),
                          tabPanel("COVID-19 Vaccine Research", DT::dataTableOutput("org.covid.vaccine.table")),
                        ), 
                        width = 12),
                        )
                 ),
                 column(5,
                        verticalLayout(
                          h4("Top authors"),
                          fluidRow(column(align = "left", DT::dataTableOutput("org.top.authors"), width = 12)),
                          h4("Top funders"),
                          fluidRow(column(align = "left", DT::dataTableOutput("org.top.funders"), width = 12)),
                          h4("Top publications"),
                          fluidRow(column(align = "left", DT::dataTableOutput("org.top.pubs"), width = 12))
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
                p("These tables show the top 50 researchers pursuing COVID-19 and vaccine research around the world, measured by their publications, citations, and altmetrics score. Use the controls here to select the ranking metric to use and whether to highlight all COVID-19 researchers, or only those pursuing research into vaccines. Selecting a researcher will show their most cited publications, as well as a visualization of their most frequently-used keywords"),
                radioButtons("author.metric", "Ranking metric:",
                             c("Publications" = "pubcount",
                               "Citations" = "citations",
                               "Altmetrics" = "altmetrics"
                             ),
                             inline = TRUE),
                column(7, align = "left",
                       fluidRow(column(tabsetPanel(
                         id = "author.tabSwitch",
                         tabPanel("All COVID-19 Research", DT::dataTableOutput("author.covid.all.table")),
                         tabPanel("COVID-19 Vaccine Research", DT::dataTableOutput("author.covid.vaccine.table")),
                        ), 
                        width = 12),
                       )
                ), # End column
                column(5,
                       verticalLayout(
                         h4("Top Publications"),
                         fluidRow(column(align = "left", DT::dataTableOutput("author.top.pubs") %>% withSpinner(color="darkgrey"), width = 12)) ,
                         h4("Top Keywords"),
                         fluidRow(column(align = "left", plotOutput("author.wordcloud") %>% withSpinner(color="darkgrey"), width = 12)),
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
                         tabPanel("COVID-19 Vaccine Research", DT::dataTableOutput("pub.covid.vaccine.table")),
                       ), 
                       width = 12),
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
                         tabPanel("COVID-19 Vaccine Research", DT::dataTableOutput("funder.covid.vaccine.table")),
                       ), 
                       width = 12),
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
                                         plotOutput("funder.recipients.countries") %>% withSpinner(color="darkgrey"), width = 6)),
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
                fluidRow(plotlyOutput("concept.projection", height = "800px") %>% withSpinner(color="darkgrey"), width = 12) ,
                width = 12
              ) # End mainPanel
            ), # End tabPanel
            #
            # TRENDS IN COVID-19 RESEARCH
            #
            tabPanel(
              "Trends",
              mainPanel(
                h4("Temporal changes in COVID-19 research"),
                width = 12
              ) # End mainPanel
            ), # End tabPanel
  ) # End navbarPage
)
