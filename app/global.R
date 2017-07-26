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


# Load utilities ----------------------------------------------------------

source("utils.R")


# Load modules ------------------------------------------------------------

source("modules/sights/global.R")
