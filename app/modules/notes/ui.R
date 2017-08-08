###########################################################
# UI definitions for the NOTES module
# 
# Author: Stefan Schliebs
# Created: 2017-07-31
###########################################################


notesModuleUI <- function(id) {
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

    
    # Wordcloud ---------------------------------------------------------------
    
    material_card(
      fluidRow(
        column(
          width = 8,
          div(
            id = ns("wordcloud-help"),
            d3wordcloudOutput(ns("wordcloud"))
          )
          
        ),
        column(
          width = 4,
          div(
            id = ns("sentiment_counts-help"),
            highchartOutput(ns("sentiment_counts"))
          )
        )
      )
    )
  )
}

notesModuleHelp <- function(id) {
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
      id = ns("wordcloud-help"),
      help = "Some UFO sighting records have free-text notes linked to them. 
        Based on the selected filters above, a word cloud showing most frequent 
        words in these notes is shown here."
    ),
    list(
      id = ns("sentiment_counts-help"),
      help = "Here the distribution of sentiments in the free-text notes is shown.
        Click on the bars to filter the word cloud to show only words of a certain
        sentiment. The chosen sentiment is highlighted in the bar chart."
    )
  )
  
  data.frame(
    element = lapply(help_defs, function(x) paste0("#", x$id)) %>% unlist(),
    intro = lapply(help_defs, function(x) x$help) %>% unlist()
  )
}
