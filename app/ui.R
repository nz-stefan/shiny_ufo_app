###########################################################
# UI definitions for the app
# 
# Author: Stefan Schliebs
# Created: 2017-07-25
###########################################################


# Header ------------------------------------------------------------------

db_header <- dashboardHeader(disable = F, title = "UFO Sightings")


# Sidebar -----------------------------------------------------------------

db_sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Start", tabName = "start", icon = icon("home")),
    menuItem("UFO sightings", tabName = "sights", icon = icon("line-chart")),
    menuItem("UFO comments", tabName = "notes", icon = icon("comments-o"))
  ), 
  collapsed = TRUE
)


# Body --------------------------------------------------------------------

db_body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css")
  ),
  
  tabItems(
    
    # Sights ------------------------------------------------------------------
    
    tabItem(
      tabName = "sights",
      sightsModuleUI("sights_module")
    ),
    
    
    # Notes -------------------------------------------------------------------
    
    tabItem(
      tabName = "notes"#,
      # trendsModuleUI("notes_module")
    ),
    
    
    # Start -------------------------------------------------------------------
    
    tabItem(
      tabName = "start",
      # rankModuleUI("about_module")
      material_card(
        header = tags$img(src = "simpson-aliens.png", width = "100%", height = "400px"),
        h1("UFO Sightings"),
        h3("Reports of unidentified flying object reports in the last century"),
        p("This dataset contains over 80,000 reports of UFO sightings over the last century.
          collected by the National UFO Reporting Center (NUFORC). It is publicly available
          at ", tags$a("GitHub", href = "https://github.com/planetsig/ufo-reports"), "."),
        p("The dataset was chosen in this demo because of its mixture of geolocation, time
          series and textual information.
          This app is implemented in the ", tags$a("R Shiny", "https://shiny.rstudio.com"),
          " web application framework. The code is available is available on ",
          tags$a("GitHub", href = "https://github.com/nz-stefan/shiny_ufo_app"), ".")
      )
    )
  )
)


# Dashboard ---------------------------------------------------------------

ui <- dashboardPage(
  db_header,
  db_sidebar,
  db_body,
  skin = "red"
)
