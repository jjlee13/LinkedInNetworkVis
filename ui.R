
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(
  
  titlePanel("LinkedIn Web Scraping"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    
    sidebarPanel(
      
      fluidRow(
      
      h5("Please Run R Package Beforehand.\n
         Required files: connection.txt, top_15.txt"
         ),
      
      radioButtons("radio", label = h3("Choose Visualization"), 
                   choices = list("Recommender"=1, "Word Cloud"=2),
                   selected=1),
      conditionalPanel(
        condition="input.radio == 2",
        sliderInput("slider", label = h3("Number of Connections"), min = 0, 
                max = 500, value = 0)
        
      )

      )
    ),
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("plot"),
      conditionalPanel(
        condition="input.radio == 2",
        tableOutput("dataframe")    
      )

    )
  )
))
