###########################################################
# Prepare dataset for Shiny app
# 
# Author: Stefan Schliebs
# Created: 2017-07-25
###########################################################


library(tidyverse)
library(lubridate)


# Config ------------------------------------------------------------------

DATA_URL <- "https://github.com/planetsig/ufo-reports/raw/master/csv-data/ufo-scrubbed-geocoded-time-standardized.csv"


# Get data ----------------------------------------------------------------

# load data from URL
d.ufo <- read_csv(
  url(DATA_URL),
  col_names = c("datetime", "city", "state", "country", "shape", "duration", "duration_pretty", "comments", "date_posted", "latitude", "longitude"),
  col_types = "cccccicccdd"
)


# Clean fields ------------------------------------------------------------

d.ufo_clean <- d.ufo %>% 
  filter(!is.na(longitude) & !is.na(latitude)) %>% 
  mutate(
    datetime = strptime(datetime, "%m/%e/%Y %H:%M") %>% as.POSIXct(),
    country_extract = str_match(city, "\\(([\\w|/|\\s]+)\\)$") %>% .[,2],
    country = ifelse(is.na(country), country_extract, country)
    # TODO: Clean up case of city and country names
  ) %>% 
  select(-country_extract)


# Add fields --------------------------------------------------------------

make_html_table <- function(datetime, city, country, shape, duration) {
  HTML_TEMPLATE <- "<table>
  <tr><td>Time:</td><td>%s</td></tr>
  <tr><td>Location:</td><td>%s</td></tr>
  <tr><td>Shape:</td><td>%s</td></tr>
  <tr><td>Duration</td><td>%s</td></tr>
  </table"
  
  location <- ifelse(is.na(country), city, sprintf("%s (%s)", city, country))
  sprintf(HTML_TEMPLATE, datetime, location, shape, duration)
}

d.ufo_final <- d.ufo_clean %>% 
  mutate(
    date = as.Date(datetime),
    year = year(date),
    month = month(date),
    day_of_week = wday(date, label = T),
    hour_of_day = hour(datetime),
    html_label = make_html_table(strftime(datetime, "%b %d %Y at %l%p"), city, country, shape, duration_pretty)
  ) %>% 
  select(datetime, date, year, month, day_of_week, hour_of_day, city, country, shape, duration, duration_pretty, latitude, longitude, comments, html_label)


# Export ------------------------------------------------------------------

write_rds(d.ufo_final, "app/data/ufo-cleaned.rds")
