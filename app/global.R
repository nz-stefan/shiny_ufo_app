###########################################################
# Entry point of the app
# 
# Author: Stefan Schliebs
# Created: 2017-07-25
###########################################################


library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinycssloaders)
library(shinyjs)
library(leaflet)
library(highcharter)
library(DT)
library(tidyverse)
library(d3wordcloud)
library(rintrojs)


# Load utilities ----------------------------------------------------------

source("utils/ui-utils.R")
source("utils/filter.R")


# Load modules ------------------------------------------------------------

source("modules/sights/global.R")
source("modules/start/global.R")
source("modules/notes/global.R")
