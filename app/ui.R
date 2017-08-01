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
  # include shinyjs globally (must be included once only)
  useShinyjs(),
  
  # add CSS customizations
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css")
  ),

  # make sidebar collapse when a menu item is clicked
  tags$script("$('.sidebar-menu a').click(function (e) {
        $('body').addClass('sidebar-collapse');
        $('body').removeClass('sidebar-open');
      });"),

  # set a max width for the content (looks nicer on larger screens)
  tags$script("$('.content-wrapper').addClass('fixed-width');"),

  # add content for each menu item
  tabItems(
    
    # Sights ------------------------------------------------------------------
    
    tabItem(
      tabName = "sights",
      sightsModuleUI("sights_module")
    ),
    
    
    # Notes -------------------------------------------------------------------
    
    tabItem(
      tabName = "notes",
      notesModuleUI("notes_module")
    ),
    
    
    # Start -------------------------------------------------------------------
    
    tabItem(
      tabName = "start",
      startModuleUI("start_module")
    )
  )
)


# Dashboard ---------------------------------------------------------------

ui <- dashboardPage(
  db_header,
  db_sidebar,
  db_body,
  skin = "green"
)
