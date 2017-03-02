
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
source("C:/Users/justi_000/Desktop/project_shiny/all_functions.R")


shinyServer(function(input, output) {
  
  output$dataframe <- renderTable({
      h3("Connection Dataframe")
      df = read.table("connection.txt",header=TRUE, row.names = 1)
      df[,1] %>% gsub("\\+","",.) %>% as.numeric ->a
      df = df[a>=input$slider,]
      rownames(df)=NULL
      return (df)
    })
  
  output$plot <-renderPlot({
      if(input$radio==1){
        df = read.table("top_15.txt", header=TRUE)
        require(ggplot2)
        require(grid)
        require(dplyr)
        
        myPalette <- colorRampPalette(rev(brewer.pal(11, "Spectral")))
        sc <- scale_colour_gradientn(colours = myPalette(100), limits=c(1, 8))
        
        ggplot(df)+geom_bar(stat="identity", aes(x=Names, y=Freq, fill=Freq))+ ggtitle("Connection Recommender Based on People Also Viewed")+theme_bw()+xlab("Names")+ylab("Number of Suggestions")+ sc+coord_flip()+theme(legend.position="none")
      }else{
        df = read.table("connection.txt",header=TRUE, row.names = 1)
        df[,1] %>% gsub("\\+","",.) %>% as.numeric ->a
        df = df[a>=input$slider,]
        rownames(df)=NULL
        
        
        par(mfrow=c(2,2))
        cloud_title(df)
        cloud_company(df)
        cloud_industry(df)
        cloud_education(df)
        }
    })
})

