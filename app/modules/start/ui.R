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
    h1("UFO Sightings"),
    h3("Reports of unidentified flying objects in the last century"),
    p("This dataset contains over 80,000 reports of UFO sightings over the last century.
      collected by the National UFO Reporting Center (NUFORC). It is publicly available
      at ", tags$a("GitHub", href = "https://github.com/planetsig/ufo-reports"), " and",
      tags$a("Kaggle", href = "https://www.kaggle.com/donyoe/exploring-ufo-sightings"), "."),
    p("The dataset was chosen in this demo because of its mixture of geolocation, time
      series and textual information.
      This app is implemented in the ", tags$a("R Shiny", href = "https://shiny.rstudio.com"),
      " web application framework. The code is available on ",
      tags$a("GitHub", href = "https://github.com/nz-stefan/shiny_ufo_app"), ".")
  )
}
 