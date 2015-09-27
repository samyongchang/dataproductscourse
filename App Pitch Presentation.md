App Pitch Presentation
========================================================
author: Chen Yongchang
date: 27 Aug 2015



Overview of App
========================================================
This presentation will give an overview of the "World Healthcare Data 1995 to 2013" [App Link](https://samyongchang.shinyapps.io/DataProductsProject)
The Github for more details can be found [Here](https://github.com/samyongchang/dataproductscourse.git). In it further details on how the data is processed and the shiny scripts can be found.

The app provides the following 
- Summary Statistics of Countries from selected WorldBank Healthcare Data from 1995 to 2013
- Comparison of a selected country's statistics with the average in the dataset. Comparison is based on a time series plot and a correlation number.
- A Motion Chart of the Dataset using GoogleVis

Data Inputs: Data Source & Indicators
========================================================
The data used is from the [World Development Indicators](http://data.worldbank.org/topic/health) data base from the World Bank website. The raw data can be downloaded [here]("http://api.worldbank.org/v2/en/topic/8?downloadformat=csv"). The data was preprocessed to include only selected statistics for the purpose of this project as well as for their completeness. The final indicators are in the list below. The time-series are from the period 1995-2013.

<font size="5.5">  

```r
chartdata <- readRDS("chartdata.rds")
# Shw List of Indicators in Data
names(chartdata)[3:15]
```

```
 [1] "Birth rate, crude (per 1,000 people)"                               
 [2] "Death rate, crude (per 1,000 people)"                               
 [3] "Health expenditure per capita (current US$)"                        
 [4] "Health expenditure per capita, PPP (constant 2011 international $)" 
 [5] "Health expenditure, public (% of GDP)"                              
 [6] "Health expenditure, public (% of government expenditure)"           
 [7] "Health expenditure, total (% of GDP)"                               
 [8] "Life expectancy at birth, total (years)"                            
 [9] "Out-of-pocket health expenditure (% of total expenditure on health)"
[10] "Population ages 15-64 (% of total)"                                 
[11] "Population ages 65 and above (% of total)"                          
[12] "Population, female (% of total)"                                    
[13] "Population, total"                                                  
```
</font>

Data Inputs: Available Countries
========================================================
- A total of 172 countries are in the dataset
- Below we present the first 30 countries in the dataset
<font size="5"> 

```r
# Number of Countries
length(unique(chartdata$Country.Name))
```

```
[1] 172
```

```r
# Sample List of Countries in Dataset
unique(chartdata$Country.Name)[1:30]
```

```
 [1] Albania                Algeria                Angola                
 [4] Antigua and Barbuda    Argentina              Armenia               
 [7] Australia              Austria                Azerbaijan            
[10] Bahamas, The           Bahrain                Bangladesh            
[13] Barbados               Belarus                Belgium               
[16] Belize                 Benin                  Bhutan                
[19] Bolivia                Bosnia and Herzegovina Botswana              
[22] Brazil                 Brunei Darussalam      Bulgaria              
[25] Burkina Faso           Burundi                Cabo Verde            
[28] Cambodia               Cameroon               Canada                
249 Levels: Afghanistan Albania Algeria American Samoa Andorra ... Zimbabwe
```
</font>

App Functions 1: Summary & Comparison with Overall
========================================================
Above are screenshots of 2 tabs of the app.

Tab 1 (Summary Statistics) allows a user to select the Country they are interested in to generate key statistics like mean and median.

Tab 2 (Comparison with Overall) compare a specific Country's key statistic (selected from the drop down) and compare it with the overall average.

<div class="midcenter" style="margin-left:-400px; margin-top:-450px;"><img src="screenshot1.png" height="400" width="400"></img></div>




App Functions 2: Motion Plot
========================================================
A motion plot is also indicated in one of the tabs.
The drop down selections do not affect the selections here. 
Instead the selections available in the GoogleVis Motion Chart options can be selected to see how the data changes over time. 
<img src="screenshot2.png" height="550" width="800"></img></div>
