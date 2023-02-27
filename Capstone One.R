library(tidyverse)
library(lubridate)
url_confirmed <- 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv'
covid_data_RAW <- read_csv(url_confirmed)
glimpse(covid_data_RAW)
str(covid_data_RAW)
#head(covid_data_RAW(5))

#%>% this pipe renames the columns of the covid_data_RAW data frame and create a new data frame called covid_data 
covid_data_RAW %>% 
  rename('subregion' = `Province/State` 
         ,'country' = 'Country/Region'
         ,'lat' = 'Lat'
         ,'long' = 'Long'
  ) ->
  covid_data

#pivot_longer() function takes a data frame as input, and creates a new data frame with more rows and fewer columns.
#Be careful! when you're manipulating your data like this test the code several times, to make sure that it works before you overwrite your input data!
covid_data %>% 
  pivot_longer(cols = -one_of('country','subregion','lat','long')
               ,names_to = 'date'
               ,values_to = 'confirmed'
  ) ->
  covid_data
head(covid_data)

# REORDER COLUMNS

covid_data %>% 
  select(country, subregion, everything()) ->
  covid_data
covid_data %>% 
  select(date)
#mdy() transforms character dates of the MONTH-DAY-YEAR form into R dates, dmy()=day, month, year
# CONVERT DATE
#-------------
library(lubridate)

covid_data %>% 
  mutate(date = mdy(date)) ->
  covid_data
head(covid_data)
# SORT & REARANGE DATA

# … with abbreviated variable names ¹​subregion,
#   ²​confirmed
covid_data %>% 
  select(country, subregion, date, lat, long, confirmed) %>% 
  arrange(country, subregion, date) ->
  covid_data
#double check to make sure everything is "clean" enough
# GET COUNTRY NAMES
covid_data %>% 
  select(country) %>% 
  unique() #%>% print(n = 200)
# don't need to look at all 200 but I might need the full list later so I just commented out print
#U.S. data pull using the dplyr filter function to subset data frame

#this why r uses pipe instead of nestling functions inside other functions # https://towardsdatascience.com/understanding-the-native-r-pipe-98dea6d8b61b#:~:text=Since%20R%20is%20prone%20to,%3A%20LHS%20%25%3E%25%20RHS%20.
#I did not know/remember/or realize that the assignment operator <- existed  but it assigns the result of the right-hand side expression to the variable name on the left-hand side (i know it self explanatory)

covid_data %>%
  select(country,date,confirmed) %>%
  filter(country == 'US') %>%
  group_by(country,date) %>%
  summarise(confirmed = sum(confirmed))

# compare with the JHU data for the US on January 22, 2020
# (as of September 2021, the JHU data for January 22, 2020 is not available)

# filter the data for the US on January 22, 2020
us_data <- covid_data %>%
  filter(country == "US", date == "2020-01-22")

# view the confirmed cases for the US on January 22, 2020
us_data$confirmed
#[1] 1 ? weak, do the whole month of feb JHU data for jan no longer availabler

us_feb_data <- covid_data %>%
  filter(country == "US", month(date) == 2, year(date) == 2020)

# calculate the total number of confirmed cases for the US in feb 2020
us_feb_cases <- sum(us_feb_data$confirmed)

us_feb_data$confirmed
str(us_feb_data$confirmed)

# getting data, cleaning it an  for the "confirmed" cases took longer than expected (almost a whole day) and I still need the datasets for “deaths” and “recovered” cases. in retrospect I should've used the same tatic I used for Spaceship titanic and treat them as one file. Coding 101, code smarter (repeatable process), not harder. create functions that will clean/wrangle all 3. like nestleing, NO! like piping covid_data_rename into Covid_rename_columns that uses datasets as an argument  and the assingment operator that was hiding in plain sight <- (find the hot key for it)

#function to rename cloumns in all 3 data sets
covid_rename_columns <- function(input_data){
  input_data %>% 
    rename('subregion' = 'Province/State'
           ,'country' = 'Country/Region'
           ,'lat' = 'Lat'
           ,'long' = 'Long'
    ) ->
    output_data
  return(output_data)
}
#use the output of the rename() process and save it as output_data, (which we’re returning from the function.)

#redo pivot_longer() next
covid_pivot_data <- function(input_data, value_var_name){
  input_data %>% 
    pivot_longer(cols = -one_of('country','subregion','lat','long')
                 ,names_to = 'date'
                 ,values_to = value_var_name
    ) ->
    output_data
  return(output_data)
}

#redo R dates

covid_convert_dates <- function(input_data){
  input_data %>% 
    mutate(date = mdy(date)) ->
    output_data
  return(output_data)
}
# rearrange the variables

covid_rearrange_data <- function(input_data){
  input_data %>% 
    select(country, subregion, date, lat, long, everything()) %>% 
    arrange(country, subregion, date) ->
    output_data
  return(output_data)
}

#now put all of them into one last function that will retrieve and wrangle after define in the URL locations

covid_get_data <- function(input_url, value_var_name){
  covid_data_inprocess <- read_csv(input_url)
  covid_data_inprocess <- covid_rename_columns(covid_data_inprocess)
  covid_data_inprocess <- covid_pivot_data(covid_data_inprocess, value_var_name)
  covid_data_inprocess <- covid_convert_dates(covid_data_inprocess)
  covid_data_inprocess <- covid_rearrange_data(covid_data_inprocess)
  return(covid_data_inprocess)
}

url_confirmed = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv'
url_deaths = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv'
url_recovered = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv'

covid_confirmed = covid_get_data(url_confirmed,'confirmed')
covid_deaths = covid_get_data(url_deaths,'dead') 
covid_recovered = covid_get_data(url_recovered,'recovered')
# use the print() function along with the paste() function in R to print 3 different inputs  without having to run print 3 times

input1 <- covid_confirmed
input2 <- covid_deaths
input3 <- covid_recovered

#output <- paste(input1, input2, input3)
#print(output)

#maybe I should've used count instead of print
count(covid_confirmed)
count(covid_deaths)
count(covid_recovered)

#drop dups columns using the select() method then merg data
covid_deaths <- covid_deaths %>% select(-long, -lat)
covid_recovered <- covid_recovered %>% select(-long, -lat)

# use left_join() to join the three files together on country, subregion, and date.

covid_confirmed %>% 
  left_join(covid_deaths, on = c(country, subregion, date)) %>% 
  left_join(covid_recovered, on = c(country, subregion, date)) ->
  covid_data

print(covid_data, nrow= 10)

#add newest cases (and a new column fir it) throw it back in to covid_data
covid_data %>% 
  arrange(country, subregion, date) %>% 
  group_by(country, subregion) %>% 
  mutate(new_cases = confirmed - lag(confirmed)) %>% 
  ungroup() ->
  covid_data

print(tail(covid_data))

# do the rest in Python
#knowing your data helps you understand what visualizations you can use
#Numeric variables and date variables can be used for line charts. 
#Pairs of numeric variables can also be used for scatterplots.

#the U.S. does not have sub_regions (take it out)

covid_data %>% 
  filter(date == as_date('2020-05-07')) %>% 
  select(country, confirmed, dead, recovered) %>% 
  group_by(country) %>% 
  summarise(dead = sum(dead)
            ,confirmed = sum(confirmed)
  ) %>% 
  ggplot(aes(x = confirmed, y = dead)) +
  geom_point()

#what is going on with that country Being represented in the upper rt hand corner? who is it? will bar chart work better?
covid_data %>% 
  filter(date == as_date('2020-05-07')) %>% 
  select(country, confirmed) %>% 
  group_by(country) %>% 
  summarise(confirmed = sum(confirmed)) %>% 
  arrange(-confirmed) %>% 
  top_n(15) %>% 
  ggplot(aes(x = country, y = confirmed)) +
  geom_bar(stat = 'identity', fill = 'darkred') 
#chart looks better but can't read the y-axis. remember the banks and try horizontal by changing x and y
covid_data %>% 
  filter(date == as_date('2020-05-07')) %>% 
  select(country, confirmed) %>% 
  group_by(country) %>% 
  summarise(confirmed = sum(confirmed)) %>% 
  arrange(-confirmed) %>% 
  top_n(15) %>% 
  ggplot(aes(y = fct_reorder(country, confirmed), x = confirmed)) +
  geom_bar(stat = 'identity', fill = 'darkblue') +
  labs(y = '')

#fct_reorder(.f, .x, .fun = NULL, .default = NA_real_, ...)

#.f is the factor variable to be reordered.
#.x is the variable used for reordering the levels of .f.
#.fun is an optional function used to compute the summary statistic for reordering. By default, mean is used.
#.default is an optional default value for missing values in .x.
#... are additional arguments passed to the summary function .fun.

#line charts to show cases over time minus China because of their scary ballons by filtering down to where country is no China and aggregate the data by date

covid_data %>% 
  filter(country != 'China') %>% 
  group_by(date) %>% 
  summarise(confirmed = sum(confirmed)) %>% 
  ggplot(aes(x = date, y = confirmed)) +
  geom_line(color = 'red')
view(date)

#China on 1 line the world on the other.
#remember scale_color_manual() to specify different colors for the two different lines.

covid_data %>% 
  mutate(china_ind = if_else(country == 'China', 'China', 'Not China')) %>%
  group_by(china_ind, date) %>% 
  summarise(confirmed = sum(confirmed)) %>% 
  ggplot(aes(x = date, y = confirmed)) +
  geom_line(aes(color = china_ind)) +
  scale_color_manual(values = c('navy', 'red'))

#top 5 important nations 
covid_data %>% 
filter(country %in% c("US","China","Italy","Spain","France")) %>% 
  group_by(country, date) %>% 
  summarise(confirmed = sum(confirmed)) %>% 
  ggplot(aes(x = date, y = confirmed)) +
  geom_line(aes(color = country)) +
  scale_color_manual(values = c('navy', 'red','green', 'purple', 'orange'))

library(readxl)



cbutors <-covid_data_com <- read.csv("C:\\Users\\franc\\OneDrive\\Documents\\Data Engineering\\Capstone 1\\Conditions_Contributing_to_COVID-19_Deaths__by_State_and_Age__Provisional_2020-2023.csv")
tail(cbutors)
str(cbutors)

library(lubridate)


cbutors %>% 
  rename('Date' = `Data.As.Of` 
         ,'country' = 'State'         
  ) ->
  glimpse(cb)

who <- who_covid_data <- read.csv("C:\\Users\\franc\\OneDrive\\Documents\\Data Engineering\\Capstone 1\\WHO_covid-data.csv")
 glimpse(who)
 view(who)
 
 
 library(lubridate)
 #=========
 file_path <- "https://www.sharpsightlabs.com/datasets/covid19/covid_data_2020-05-08.csv"
 covid_data <- read_delim(file_path,delim = ";")
 
 covid_data %>% 
   filter(date == as_date('2020-05-03')) %>% 
   group_by(country) %>% 
   summarise(confirmed = sum(confirmed)) %>% 
   arrange(-confirmed) %>% 
   top_n(12, confirmed) ->
   covid_top_12
 
 #--------------------------
 # PLOT SMALL MULTIPLE CHART
 #--------------------------
 covid_data %>% 
   filter(country %in% covid_top_12$country) %>% 
   group_by(country, date) %>% 
   summarise(new_cases = sum(new_cases)) %>%
   ggplot(aes(x = date, y = new_cases)) +
   geom_line() +
   facet_wrap(~country, ncol = 4)
 
library(ggplot2)
 library(readr)
 library(dplyr)
 library(ggplot2)
 
 
 
 # Read data from CSV file
 # Read data from CSV file
 covid_data <- read_csv("covid_data.csv")
 contributing_data <- read_csv( "C:\\Users\\franc\\OneDrive\\Documents\\Data Engineering\\Capstone 1\\Conditions_Contributing_to_COVID-19_Deaths__by_State_and_Age__Provisional_2020-2023.csv")
 
 
 # Merge the cases and deaths data based on the date column
 covid_data <- inner_join( covid_data, by = "date")
 
 ggplot(covid_data, aes(x = date)) +
   geom_line(aes(y = deaths, color = "Deaths")) +
   geom_line(aes(y = condition_group, color = "Condition Group")) + # Add new line
   scale_color_manual(values = c( "Deaths" = "red", "Condition Group" = "green")) + # Update color scale
   labs(title = "COVID-19 Cases, Deaths with Underlying Condition Groups", y = "Number of Cases/Deaths/Condition Groups", color = "Metric") +
   theme_minimal()
 
 
 









