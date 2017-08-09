###########################################################
# UI definitions for the START module
# 
# Author: Stefan Schliebs
# Created: 2017-07-29
###########################################################


startModuleUI <- function(id) {
  # obtain namespace
  ns <- NS(id)

  material_card(
    header = tags$img(src = "cow-ufo.jpg", width = "100%"),
    h1("R Shiny Demo Application"),
    p("This is a demo web application written in the R Shiny framework. The app
      demonstrates the use of various UX components commonly seen in data products.
      In particular the demo showcases:",
      tags$ul(
        tags$li("Clean and responsive UI that works well on both large and small screens"),
        tags$li("Reasonable app performance and visual feedback during re-calculations"),
        tags$li("Standard visualisations, like (stacked) area and bar charts"),
        tags$li("Maps including clustering of markers"),
        tags$li("Wordclouds"),
        tags$li("Info tiles"),
        tags$li("Various UX components such as multiple pages, pulldown menus, sliders, radio buttons and switches"),
        tags$li("Help system"),
        tags$li("Modular structure of the app's code")
      )
    ),
    h3("Data"),
    p("The dataset contains over 80,000 reports of UFO sightings over the last century.
      collected by the National UFO Reporting Center (NUFORC). It is publicly available
      at ", tags$a("GitHub", href = "https://github.com/planetsig/ufo-reports"), " and",
      tags$a("Kaggle", href = "https://www.kaggle.com/donyoe/exploring-ufo-sightings"), "."),
    p("The dataset was chosen because of its quirkyness and its mixture of geolocation, time
      series and textual information which allows various interesting visualisations like
      maps and wordclouds. It was also easy to enrich this dataset using other data sources
      such as the country polygons in the ", tags$code("rworldmap"), " package to identify the 
      correct country of a particular geolocation or adding sentiment to the textual comments
      of an UFO sighting using the ", tags$code("tidytext"), " package."),
    h3("Code"),
    p("This app is implemented in the ", tags$a("R Shiny", href = "https://shiny.rstudio.com"),
      " web application framework. The code is available on ",
      tags$a("GitHub", href = "https://github.com/nz-stefan/shiny_ufo_app"), ".
      In total, less than ", tags$strong("1,200 lines of code and CSS"), " were written for 
      this app over a course of ", tags$strong("less than 40 hours"), ". The development time 
      included data preparation and figuring out what to actually develop and how to best 
      present the information."),
    h3("Deployment"),
    p("The app is deployed through RStudio's webservice ", 
      tags$a("shinyapps.io", href = "https://shinyapps.io"), " which is straightforward to 
      achieve and fairly reasonably priced. However, the app can be easily ", 
      tags$a("containerized", href = "https://www.docker.com"), " and deployed through a secured 
      VM or a Kubernetes cluster.")
  )
}


startModuleHelp <- function(id) {
  ns <- NS(id)
  
  help_defs <- list(
    list(
      id = NA,
      help = "Open the menu by clicking on the drawer symbol in the title to navigate 
        to a particular page in the report. For each page additional help is available."
    )
  )
  
  data.frame(
    element = lapply(help_defs, function(x) paste0("#", x$id)) %>% unlist(),
    intro = lapply(help_defs, function(x) x$help) %>% unlist()
  )
}
