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
                 column(6, align = "left",
                        fluidRow(column(tabsetPanel(
                          id = "org.tabSwitch",
                          tabPanel("All COVID-19 Research", DT::dataTableOutput("org.covid.all.table")),
                          tabPanel("COVID-19 Vaccine Research", DT::dataTableOutput("org.covid.vaccine.table")),
                        ), 
                        width = 12),
                        )
                 ),
                 column(6,
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
                column(6, align = "left",
                       fluidRow(column(tabsetPanel(
                         id = "author.tabSwitch",
                         tabPanel("All COVID-19 Research", DT::dataTableOutput("author.covid.all.table")),
                         tabPanel("COVID-19 Vaccine Research", DT::dataTableOutput("author.covid.vaccine.table")),
                        ), 
                        width = 12),
                       )
                ), # End column
                column(6,
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
  ) # End navbarPage
)
