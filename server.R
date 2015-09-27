
# Load data
chartdata <- readRDS("chartdata.rds")

# Create an table with the average of all attributes
dgroup <- aggregate(chartdata[3:15], by = list(chartdata$Year), FUN="mean")
names(dgroup)[1] <- "Year"

library(shiny)
library(googleVis)
require(devtools)
library(psych)
library(ggplot2)
library(dplyr)


shinyServer(

  
  function(input, output) {
    
  # Summary Tables   
    output$selectedcountry <- renderText({paste("Selected Country:", input$countryid, sep=" ")})
    output$summarytable <- renderTable({
                          describe(chartdata[chartdata$Country.Name==paste(input$countryid,sep=""),])[c(-1,-2),c(3:5,8:10)]
                         })
  # Plot motion chart
    output$plot1 <- renderGvis({
      gvisMotionChart(chartdata,"Country.Name", "Year", 
                           options= list(width=1000, height=500))})
  
  # Plot Line Chart that compares with 
    
    output$plot2 <- renderPlot({
                      
                      num <- match(input$stat1, names(dgroup))
                      
                      cdata <- reactive({chartdata[chartdata$Country.Name==input$countryid,]})
                      charting <- cdata()
                  
                      numc <- match(input$stat1, names(charting))
                      corrnum <- cor(charting[,numc], dgroup[,num])
                      
                      plot(x=charting$Year, y=charting[,numc], type="l", col="steel blue", lwd=4,
                           xlab = "Year", ylab = as.character(input$stat1), ylim=c(min(chartdata[,numc]), max(chartdata[,numc])), xlim=c(1995,2013) 
                           )
                      
                      par(new=T)
                      plot(x=dgroup$Year, dgroup[,num] , type = "l", col="black", xlab="", ylab="", lwd=1, ylim=c(min(chartdata[,numc]), max(chartdata[,numc])), xlim=c(1995,2013))
                      par(new=F)
                      legend("topright", col=c("steel blue","black"), lty=1, lwd=1, bty="n",
                             legend=c(input$countryid, "Overall"))
                      text(1998, max(chartdata[,numc]), paste("Correlation with Overall=", round(corrnum,digits=2), cex=2))
                      
                      })
      
      
  })                            

