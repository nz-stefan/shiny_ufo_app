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
          sliderInput(ns("year"), label = "Select sighting year range", min = 1906, max = 2014, value = c(1924, 1964), sep = "", width = "100%")
        ),
        column(
          width = 6,
          uiOutput(ns("filter_continent")) %>% withSpinner(type = 3, color.background = "white")
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
          width = 12, offset = 0,
          leafletOutput(ns("map"), height = 300) %>% withSpinner(type = 3, color.background = "white")
        )
      )
    ),
    
    
    # Time series UI ----------------------------------------------------------

    material_card(
      fluidRow(
        column(
          width = 2,
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
        ),
        column(
          width = 10,
          pickerInput(
            ns("date_plot_column"), 
            label = NULL, 
            choices = c("Total observations" = "obs_total", "Observations by continent" = "obs_by_continent"),
            selected = "obs_total",
            multiple = FALSE,
            width = "auto",
            options = list(style = "btn-chart")
          ),
          style = "text-align: right"
        ),
        
        # column(
        #   width = 2, 
        #   switchInput(
        #     ns("table_view"), 
        #     label = "TABLE", 
        #     onLabel = "ON", onStatus = "primary",
        #     offLabel = "OFF", offStatus = "warning",
        #     size = "mini"
        #   ),
        #   style = "text-align: right;"
        # ),
        column(
          width = 12,
          uiOutput(ns("date_plot_ui"))
        ),
        column(
          width = 12,
          awesomeRadio(
            ns("date_plot_dimension"), 
            label = NULL, #"Select time dimension", 
            choices = c("year" = "year", "month" = "month", "weekday" = "day_of_week", "hour" = "hour_of_day"),
            selected = "year",
            status = "success",
            inline = TRUE
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
          highchartOutput(ns("summary_shape"), height = 250) %>% withSpinner(type = 3, color.background = "white")
        ),
        column(
          width = 4,
          highchartOutput(ns("summary_duration"), height = 250) %>% withSpinner(type = 3, color.background = "white")
        ),
        column(
          width = 4,
          highchartOutput(ns("summary_country"), height = 250) %>% withSpinner(type = 3, color.background = "white")
        )
      )
    ),
    
    receiveSweetAlert(messageId = ns("msg_too_many_items"))
  )
}
