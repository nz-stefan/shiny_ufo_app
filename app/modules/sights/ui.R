###########################################################
# UI definitions for the SIGHTS module
# 
# Author: Stefan Schliebs
# Created: 2017-07-25
###########################################################


sightsModuleUI <- function(id) {
  # obtain namespace
  ns <- NS(id)

  tagList(

    # Filter UI ---------------------------------------------------------------

    material_card(
      fluidRow(
        column(
          width = 12,
          div(
            id = ns("year-help"),
            sliderInput(ns("year"), label = "Select sighting year range", min = 1906, max = 2014, value = c(1924, 1964), sep = "", width = "100%")
          )
        ),
        column(
          width = 6,
          div(
            id = ns("filter_continent-help"),
            uiOutput(ns("filter_continent")) %>% withSpinner(type = 3, color.background = "white")
          )
        ),
        column(
          width = 6,
          div(
            id = ns("filter_shape-help"),
            uiOutput(ns("filter_shape")) %>% withSpinner(type = 3, color.background = "white")
          )
          
        )
      )
    ),
    

    # Info boxes --------------------------------------------------------------
    
    div(
      id = ns("totals-help"),
      fluidRow(
        infoBoxOutput(ns("total_sightings")),
        infoBoxOutput(ns("total_duration")),
        infoBoxOutput(ns("total_countries"))
      ),
      style = "margin-top: 15px; margin-bottom: -10px"
    ),

    
    # Map UI ------------------------------------------------------------------
    
    div(
      id = ns("map-help"),
      class = "card",
      leafletOutput(ns("map"), height = 300) %>% withSpinner(type = 3, color.background = "white")
    ),
    
    
    # Time series UI ----------------------------------------------------------

    material_card(
      fluidRow(
        column(
          width = 2,
          div(
            id = ns("table_view-help"),
            radioGroupButtons(
              ns("table_view"),
              label = NULL,
              choices = c(
                `<i class='fa fa-bar-chart'></i>` = "chart",
                `<i class='fa fa-table'></i>` = "table"
              ),
              selected = "chart",
              size = "xs"
            )
          )
        ),
        column(
          width = 10,
          div(
            id = ns("date_plot_column-help"),
            pickerInput(
              ns("date_plot_column"),
              label = NULL,
              choices = c("Total observations" = "obs_total", "Observations by continent" = "obs_by_continent"),
              selected = "obs_total",
              multiple = FALSE,
              width = "auto",
              options = list(style = "btn-chart")
            )
          ),
          style = "text-align: right"
        ),
        column(
          width = 12,
          div(
            id = ns("date_plot_ui-help"),
            uiOutput(ns("date_plot_ui"))
          )
        ),
        column(
          width = 12,
          div(
            id = ns("date_plot_dimension-help"),
            awesomeRadio(
              ns("date_plot_dimension"),
              label = NULL, #"Select time dimension",
              choices = c("year" = "year", "month" = "month", "weekday" = "day_of_week", "hour" = "hour_of_day"),
              selected = "year",
              status = "success",
              inline = TRUE
            )
          ),
          style = "text-align: right;"
        )
      )
    ),
    
    
    # Summary UI --------------------------------------------------------------
    
    material_card(
      fluidRow(
        column(
          width = 4,
          div(
            id = ns("summary_shape-help"),
            highchartOutput(ns("summary_shape"), height = 250) %>% 
              withSpinner(type = 3, color.background = "white")
          )
        ),
        column(
          width = 4,
          div(
            id = ns("summary_duration-help"),
            highchartOutput(ns("summary_duration"), height = 250) %>% 
              withSpinner(type = 3, color.background = "white")
          )
        ),
        column(
          width = 4,
          div(
            id = ns("summary_country-help"),
            highchartOutput(ns("summary_country"), height = 250) %>% 
              withSpinner(type = 3, color.background = "white")
          )
        )
      )
    ),
    
    receiveSweetAlert(messageId = ns("msg_too_many_items"))
  )
}

sightsModuleHelp <- function(id) {
  ns <- NS(id)
  
  help_defs <- list(
    list(
      id = ns("year-help"),
      help = "Select the year range of the UFO sightings"
    ),
    list(
      id = ns("filter_continent-help"),
      help = "Filter the UFO sightings by the continent of occurrence"
    ),
    list(
      id = ns("filter_shape-help"),
      help = "Filter the UFO sightings by the shape of the seen object"
    ),
    list(
      id = ns("totals-help"),
      help = "These boxes show some basic counts of the filtered UFO sightings"
    ),
    list(
      id = ns("map-help"),
      help = "The map shows the locations of the UFO sightings. The sightings may be
        clustered. Click on the clusters or zoom into the map to reveal the exact 
        locations of a sighting. Click on a sighting to show details. Use the mouse 
        wheel to zoom and drag the mouse to navigate in the map."
    ),
    list(
      id = ns("table_view-help"),
      help = "Switch between a chart and a table view of the data"
    ),
    list(
      id = ns("date_plot_column-help"),
      help = "Select which variable to plot. You can choose either 'Total Observations'
        or 'Total Observations by Continent'."
    ),
    list(
      id = ns("date_plot_ui-help"),
      help = "Here appears either a chart or a table showing UFO observations by either
        year, month, day of week or hour."
    ),
    list(
      id = ns("date_plot_dimension-help"),
      help = "Select by which variable to aggregate the observations by, i.e. either
        year, month, day of week or hour."
    ),
    list(
      id = ns("summary_shape-help"),
      help = "Chart showing the number of UFO observations by shape"
    ),
    list(
      id = ns("summary_duration-help"),
      help = "Chart showing the distrubution of the duration of UFO observations"
    ),
    list(
      id = ns("summary_country-help"),
      help = "Chart showing the number of UFO observations by country. 
        Only the 10 most countries are shown."
    )
  )
  
  data.frame(
    element = lapply(help_defs, function(x) paste0("#", x$id)) %>% unlist(),
    intro = lapply(help_defs, function(x) x$help) %>% unlist()
  )
}
