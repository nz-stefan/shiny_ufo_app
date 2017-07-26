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
    menuItem("Sights", tabName = "sights", icon = icon("th")),
    menuItem("Sighting notes", tabName = "notes", icon = icon("line-chart")),
    menuItem("About this app", tabName = "about", icon = icon("line-chart"))
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
    
    
    # About -------------------------------------------------------------------
    
    tabItem(
      tabName = "about"#,
      # rankModuleUI("about_module")
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
