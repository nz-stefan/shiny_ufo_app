###########################################################
# UI definitions for the SIGHTS module
# 
# Author: Stefan Schliebs
# Created: 2017-07-25
###########################################################


sightsModuleUI <- function(id) {
  # obtain namespace
  ns <- NS(id)
  useShinyjs()

  tagList(

    # Filter UI ---------------------------------------------------------------

    material_card(
      fluidRow(
        column(
          width = 12,
          sliderInput(ns("year"), label = "Select sighting year range", min = 1906, max = 2014, value = c(1950, 1990), sep = "", width = "100%")
        ),
        column(
          width = 6,
          uiOutput(ns("filter_country")) %>% withSpinner(type = 3, color.background = "white")
        ),
        column(
          width = 6,
          uiOutput(ns("filter_shape")) %>% withSpinner(type = 3, color.background = "white")
        )
      )
    ),
    
    
    # Map UI ------------------------------------------------------------------
    
    material_card(
      fluidRow(
        column(
          width = 12,
          leafletOutput(ns("map"), height = 200) %>% withSpinner(type = 3, color.background = "white")
        )
      )
    ),
    
    
    # Time series UI ----------------------------------------------------------
    
    material_card(
      fluidRow(
        column(
          width = 10,
          awesomeRadio(
            ns("date_plot_dimension"), 
            label = "Select time dimension", 
            choices = c("year" = "year", "month" = "month", "weekday" = "day_of_week", "hour" = "hour_of_day"),
            selected = "year",
            status = "success",
            inline = TRUE
          )
        ),
        column(
          width = 2, 
          switchInput(
            ns("table_view"), 
            label = "TABLE", 
            onLabel = "ON", onStatus = "primary",
            offLabel = "OFF", offStatus = "warning",
            size = "mini"
          ),
          style = "text-align: right;"
        ),
        column(
          width = 12,
          uiOutput(ns("date_plot_ui"))
        )
      )
    ),
    
    
    # Summary UI --------------------------------------------------------------
    
    fluidRow(
      column(
        width = 4,
        material_card(highchartOutput(ns("summary_shape"), height = 250) %>% withSpinner(type = 3, color.background = "white"))
      ),
      column(
        width = 4,
        material_card(highchartOutput(ns("summary_duration"), height = 250) %>% withSpinner(type = 3, color.background = "white"))
      ),
      column(
        width = 4,
        material_card(highchartOutput(ns("summary_country"), height = 250) %>% withSpinner(type = 3, color.background = "white"))
      )
    )
  )
}
