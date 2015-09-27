library(shiny)
shinyUI(fluidPage(
  
  titlePanel("World Healthcare Data 1995 to 2013"),
  
  sidebarLayout(
    
    sidebarPanel(
      h2("Analyse Country Statistics"),
      selectInput('countryid', "Country", as.character(unique(chartdata$Country.Name))),
      h6("This changes the Summary Statistics for 1995 to 2013 & Comparison with Overall Average tabs"),
      selectInput('stat1', "Choose a Statistic", names(chartdata[,3:15])),
      h6("Select to compare with the overall average in the Comparison with Overall Average tab"),
      width=3
    ),
      
    
    mainPanel(
      
      tabsetPanel(
        position = "above",
        
        tabPanel("Summary Statistics for 1995 to 2013", 
                 verbatimTextOutput("selectedcountry"), 
                 h3("Summary Statistics"),
                 tableOutput("summarytable")), 

        tabPanel("Comparison with Overall Average",
                 h2("Selected Country & Statistics Vs. Overall"),
                 h4("Plot tracks the selected statistic compared with all countries in the dataset.
                    The correlation between the two are also show"),
                 plotOutput("plot2")),          
                
        tabPanel("Motion Plot", 
                 h2("Motion Plot"),
                 h3("Please select the required data in the fields provided"),
                 h4("(Note: Graphics may take a while to load)"),
                 htmlOutput("plot1")),

        tabPanel("Documentation Guide",
                 h6("Summary statistics for 1995 to 2013 - Select a Country and it shows summary data for the country selected"),
                 h6("Comparison with World Average - Select a Country and Statistics and it plots the selected country and the selected statistics compared to the overall"),
                h6("Motion and Comparison Plots - Select the statistics, country that you are interested in to observe how they change over time.")
                 )
          
      )
    )
  )
)
)
