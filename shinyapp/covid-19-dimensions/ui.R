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

# Define UI for application that draws a histogram
shinyUI(
  navbarPage("COVID-19 Research", 
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
                          id = "tabSwitch",
                          tabPanel("All COVID-19 Research", DT::dataTableOutput("covid.all.table")),
                          tabPanel("COVID-19 Vaccine Research", DT::dataTableOutput("covid.vaccine.table")),
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
            tabPanel("Leading authors")
  ) # End navbarPage
)
