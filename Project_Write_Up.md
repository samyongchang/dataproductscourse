# Data Project Documentation

### Introduction
The Markdown file documents what was done for the "World Healthcare Data 1995 to 2013" App. It can be found [App Here](https://samyongchang.shinyapps.io/DataProductsProject).


## Data Source

We will be using the [World Development Indicators](http://data.worldbank.org/topic/health) data base from the World Bank website. The data can be downloaded [here]("http://api.worldbank.org/v2/en/topic/8?downloadformat=csv"). The recode below 


```r
# Downloading the data

wburl <- "http://api.worldbank.org/v2/en/topic/8?downloadformat=csv"
download.file(wburl, "data.zip")
unzip("data.zip", list=TRUE)
unzip("data.zip", files=c("Metadata_Indicator_8_Topic_en_csv_v2.csv", "8_Topic_en_csv_v2.csv", "Metadata_Country_8_Topic_en_csv_v2.csv", "[Content_Types].xml"))

# Reading the data
d <- read.csv("8_Topic_en_csv_v2.csv", skip=4)
```


# The Code for the App

## Script for ui.R

```r
# This is for ui.R

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
```

## Script for server.R

```r
# Load data from the root directory
chartdata <- readRDS("chartdata.rds")

# Create an table with the average of all attributes
dgroup <- aggregate(chartdata[3:15], by = list(chartdata$Year), FUN="mean")
names(dgroup)[1] <- "Year"

library(shiny)
library(googleVis)
```

```
## 
## Welcome to googleVis version 0.5.10
## 
## Please read the Google API Terms of Use
## before you start using the package:
## https://developers.google.com/terms/
## 
## Note, the plot method of googleVis will by default use
## the standard browser to display its output.
## 
## See the googleVis package vignettes for more details,
## or visit http://github.com/mages/googleVis.
## 
## To suppress this message use:
## suppressPackageStartupMessages(library(googleVis))
```

```r
require(devtools)
```

```
## Loading required package: devtools
## WARNING: Rtools is required to build R packages, but no version of Rtools compatible with R 3.2.2 was found. (Only the following incompatible version(s) of Rtools were found:3.1)
## 
## Please download and install Rtools 3.3 from http://cran.r-project.org/bin/windows/Rtools/ and then run find_rtools().
```

```r
library(psych)
library(ggplot2)
```

```
## 
## Attaching package: 'ggplot2'
## 
## The following object is masked from 'package:psych':
## 
##     %+%
```

```r
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
## 
## The following objects are masked from 'package:stats':
## 
##     filter, lag
## 
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
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
```

## Scripts for Data Processing


```r
# Identifying Indicators of Interest
ind1 <- grepl("SH.XPD.OOPC.TO.ZS|
              SH.XPD.OOPC.ZS|SH.XPD.PCAP|SH.XPD.PCAP.PP.KD|
              SH.XPD.PUBL|SH.XPD.PUBL.GX.ZS|SH.XPD.PUBL.ZS|SH.XPD.TOTL.ZS|
              SN.ITK.DEFC.ZS|SP.DYN.CBRT.IN|SP.DYN.CDRT.IN|SP.DYN.LE00.IN|
              SP.POP.0014.TO.ZS|SP.POP.1564.TO.ZS|SP.POP.65UP.TO.ZS|
              SP.POP.GROW|SP.POP.TOTL",d$Indicator.Code)

# We Confine the data to the years 1995 to 2013 where there is Health Expenditure Data for most countries. 
df <- d[ind1,c(-2, -5:-38, -58:-60)]

# Remove Countries that have no data for Health Expenditure, Total (% of GDP)
ind2 <- df[df$Indicator.Name=="Health expenditure, total (% of GDP)",]
ind3 <- as.character(unique(ind2$Country.Name[complete.cases(ind2)]))
df <- df[df$Country.Name %in% ind3,]

# Remove Countries with no data for year 2013
ind4 <- df[is.na(df$X2013),]
df <- df[!df$Country.Name %in% as.character(unique(ind4$Country.Name)),]

# Remove remaining incomplete cases
ind5 <- df[!complete.cases(df),]
df <- df[!df$Country.Name %in% as.character(unique(ind5$Country.Name)),]

# Reshape into Time Series Format
library(reshape2)
library(plyr)
df <- melt(df, id.vars = c("Country.Name", "Indicator.Name", "Indicator.Code"), measure.vars = 4:22)

# Create a New variable for Years
start <- 1994
for (i in unique(df$variable)) {
                          start <- start + 1
                          df$Year[df$variable==paste(i,sep="")] <- start
}


# Create the final data file which consists only of 
selected <- df[,c(1,2,5,6)]
chartdata <- dcast(selected,Country.Name + Year ~ Indicator.Name)
saveRDS(chartdata, file = "chartdata.rds")
```



## List of Countries and Indicators in the final Dataset

```r
library(xtable)

# Show Final List of Countries in Data
print(xtable(data.frame(unique(chartdata$Country.Name))), floating=TRUE, comment=FALSE, type = "html", include.rownames = F)
```

<table border=1>
<tr> <th> unique.chartdata.Country.Name. </th>  </tr>
  <tr> <td> Albania </td> </tr>
  <tr> <td> Algeria </td> </tr>
  <tr> <td> Angola </td> </tr>
  <tr> <td> Antigua and Barbuda </td> </tr>
  <tr> <td> Argentina </td> </tr>
  <tr> <td> Armenia </td> </tr>
  <tr> <td> Australia </td> </tr>
  <tr> <td> Austria </td> </tr>
  <tr> <td> Azerbaijan </td> </tr>
  <tr> <td> Bahamas, The </td> </tr>
  <tr> <td> Bahrain </td> </tr>
  <tr> <td> Bangladesh </td> </tr>
  <tr> <td> Barbados </td> </tr>
  <tr> <td> Belarus </td> </tr>
  <tr> <td> Belgium </td> </tr>
  <tr> <td> Belize </td> </tr>
  <tr> <td> Benin </td> </tr>
  <tr> <td> Bhutan </td> </tr>
  <tr> <td> Bolivia </td> </tr>
  <tr> <td> Bosnia and Herzegovina </td> </tr>
  <tr> <td> Botswana </td> </tr>
  <tr> <td> Brazil </td> </tr>
  <tr> <td> Brunei Darussalam </td> </tr>
  <tr> <td> Bulgaria </td> </tr>
  <tr> <td> Burkina Faso </td> </tr>
  <tr> <td> Burundi </td> </tr>
  <tr> <td> Cabo Verde </td> </tr>
  <tr> <td> Cambodia </td> </tr>
  <tr> <td> Cameroon </td> </tr>
  <tr> <td> Canada </td> </tr>
  <tr> <td> Central African Republic </td> </tr>
  <tr> <td> Chad </td> </tr>
  <tr> <td> Chile </td> </tr>
  <tr> <td> China </td> </tr>
  <tr> <td> Colombia </td> </tr>
  <tr> <td> Comoros </td> </tr>
  <tr> <td> Congo, Dem. Rep. </td> </tr>
  <tr> <td> Congo, Rep. </td> </tr>
  <tr> <td> Costa Rica </td> </tr>
  <tr> <td> Cote d'Ivoire </td> </tr>
  <tr> <td> Croatia </td> </tr>
  <tr> <td> Cuba </td> </tr>
  <tr> <td> Cyprus </td> </tr>
  <tr> <td> Czech Republic </td> </tr>
  <tr> <td> Denmark </td> </tr>
  <tr> <td> Djibouti </td> </tr>
  <tr> <td> Dominican Republic </td> </tr>
  <tr> <td> Ecuador </td> </tr>
  <tr> <td> Egypt, Arab Rep. </td> </tr>
  <tr> <td> El Salvador </td> </tr>
  <tr> <td> Equatorial Guinea </td> </tr>
  <tr> <td> Eritrea </td> </tr>
  <tr> <td> Estonia </td> </tr>
  <tr> <td> Ethiopia </td> </tr>
  <tr> <td> Fiji </td> </tr>
  <tr> <td> Finland </td> </tr>
  <tr> <td> France </td> </tr>
  <tr> <td> Gabon </td> </tr>
  <tr> <td> Gambia, The </td> </tr>
  <tr> <td> Georgia </td> </tr>
  <tr> <td> Germany </td> </tr>
  <tr> <td> Ghana </td> </tr>
  <tr> <td> Greece </td> </tr>
  <tr> <td> Grenada </td> </tr>
  <tr> <td> Guatemala </td> </tr>
  <tr> <td> Guinea </td> </tr>
  <tr> <td> Guinea-Bissau </td> </tr>
  <tr> <td> Guyana </td> </tr>
  <tr> <td> Haiti </td> </tr>
  <tr> <td> Honduras </td> </tr>
  <tr> <td> Hungary </td> </tr>
  <tr> <td> Iceland </td> </tr>
  <tr> <td> India </td> </tr>
  <tr> <td> Indonesia </td> </tr>
  <tr> <td> Iran, Islamic Rep. </td> </tr>
  <tr> <td> Ireland </td> </tr>
  <tr> <td> Israel </td> </tr>
  <tr> <td> Italy </td> </tr>
  <tr> <td> Jamaica </td> </tr>
  <tr> <td> Japan </td> </tr>
  <tr> <td> Jordan </td> </tr>
  <tr> <td> Kazakhstan </td> </tr>
  <tr> <td> Kenya </td> </tr>
  <tr> <td> Kiribati </td> </tr>
  <tr> <td> Korea, Rep. </td> </tr>
  <tr> <td> Kuwait </td> </tr>
  <tr> <td> Kyrgyz Republic </td> </tr>
  <tr> <td> Lao PDR </td> </tr>
  <tr> <td> Latvia </td> </tr>
  <tr> <td> Lebanon </td> </tr>
  <tr> <td> Lesotho </td> </tr>
  <tr> <td> Libya </td> </tr>
  <tr> <td> Lithuania </td> </tr>
  <tr> <td> Luxembourg </td> </tr>
  <tr> <td> Macedonia, FYR </td> </tr>
  <tr> <td> Madagascar </td> </tr>
  <tr> <td> Malawi </td> </tr>
  <tr> <td> Malaysia </td> </tr>
  <tr> <td> Maldives </td> </tr>
  <tr> <td> Mali </td> </tr>
  <tr> <td> Malta </td> </tr>
  <tr> <td> Mauritania </td> </tr>
  <tr> <td> Mauritius </td> </tr>
  <tr> <td> Mexico </td> </tr>
  <tr> <td> Micronesia, Fed. Sts. </td> </tr>
  <tr> <td> Moldova </td> </tr>
  <tr> <td> Mongolia </td> </tr>
  <tr> <td> Montenegro </td> </tr>
  <tr> <td> Morocco </td> </tr>
  <tr> <td> Mozambique </td> </tr>
  <tr> <td> Myanmar </td> </tr>
  <tr> <td> Namibia </td> </tr>
  <tr> <td> Nepal </td> </tr>
  <tr> <td> Netherlands </td> </tr>
  <tr> <td> New Zealand </td> </tr>
  <tr> <td> Nicaragua </td> </tr>
  <tr> <td> Niger </td> </tr>
  <tr> <td> Nigeria </td> </tr>
  <tr> <td> Norway </td> </tr>
  <tr> <td> Oman </td> </tr>
  <tr> <td> Pakistan </td> </tr>
  <tr> <td> Panama </td> </tr>
  <tr> <td> Papua New Guinea </td> </tr>
  <tr> <td> Paraguay </td> </tr>
  <tr> <td> Peru </td> </tr>
  <tr> <td> Philippines </td> </tr>
  <tr> <td> Poland </td> </tr>
  <tr> <td> Portugal </td> </tr>
  <tr> <td> Qatar </td> </tr>
  <tr> <td> Romania </td> </tr>
  <tr> <td> Russian Federation </td> </tr>
  <tr> <td> Rwanda </td> </tr>
  <tr> <td> Samoa </td> </tr>
  <tr> <td> Sao Tome and Principe </td> </tr>
  <tr> <td> Saudi Arabia </td> </tr>
  <tr> <td> Senegal </td> </tr>
  <tr> <td> Sierra Leone </td> </tr>
  <tr> <td> Singapore </td> </tr>
  <tr> <td> Slovak Republic </td> </tr>
  <tr> <td> Slovenia </td> </tr>
  <tr> <td> Solomon Islands </td> </tr>
  <tr> <td> South Africa </td> </tr>
  <tr> <td> Spain </td> </tr>
  <tr> <td> Sri Lanka </td> </tr>
  <tr> <td> St. Lucia </td> </tr>
  <tr> <td> St. Vincent and the Grenadines </td> </tr>
  <tr> <td> Sudan </td> </tr>
  <tr> <td> Swaziland </td> </tr>
  <tr> <td> Sweden </td> </tr>
  <tr> <td> Switzerland </td> </tr>
  <tr> <td> Syrian Arab Republic </td> </tr>
  <tr> <td> Tajikistan </td> </tr>
  <tr> <td> Tanzania </td> </tr>
  <tr> <td> Thailand </td> </tr>
  <tr> <td> Togo </td> </tr>
  <tr> <td> Tonga </td> </tr>
  <tr> <td> Trinidad and Tobago </td> </tr>
  <tr> <td> Tunisia </td> </tr>
  <tr> <td> Turkey </td> </tr>
  <tr> <td> Turkmenistan </td> </tr>
  <tr> <td> Uganda </td> </tr>
  <tr> <td> Ukraine </td> </tr>
  <tr> <td> United Arab Emirates </td> </tr>
  <tr> <td> United Kingdom </td> </tr>
  <tr> <td> United States </td> </tr>
  <tr> <td> Uruguay </td> </tr>
  <tr> <td> Uzbekistan </td> </tr>
  <tr> <td> Vanuatu </td> </tr>
  <tr> <td> Venezuela, RB </td> </tr>
  <tr> <td> Vietnam </td> </tr>
  <tr> <td> Yemen, Rep. </td> </tr>
  <tr> <td> Zambia </td> </tr>
   </table>

```r
# Shw Final List of Indicators in Data
print(xtable(data.frame(names(chartdata)[3:15])), floating=TRUE, comment=FALSE, type = "html", include.rownames = F)
```

<table border=1>
<tr> <th> names.chartdata..3.15. </th>  </tr>
  <tr> <td> Birth rate, crude (per 1,000 people) </td> </tr>
  <tr> <td> Death rate, crude (per 1,000 people) </td> </tr>
  <tr> <td> Health expenditure per capita (current US$) </td> </tr>
  <tr> <td> Health expenditure per capita, PPP (constant 2011 international $) </td> </tr>
  <tr> <td> Health expenditure, public (% of GDP) </td> </tr>
  <tr> <td> Health expenditure, public (% of government expenditure) </td> </tr>
  <tr> <td> Health expenditure, total (% of GDP) </td> </tr>
  <tr> <td> Life expectancy at birth, total (years) </td> </tr>
  <tr> <td> Out-of-pocket health expenditure (% of total expenditure on health) </td> </tr>
  <tr> <td> Population ages 15-64 (% of total) </td> </tr>
  <tr> <td> Population ages 65 and above (% of total) </td> </tr>
  <tr> <td> Population, female (% of total) </td> </tr>
  <tr> <td> Population, total </td> </tr>
   </table>


