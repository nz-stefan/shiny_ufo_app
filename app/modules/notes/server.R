###########################################################
# Server logic for the NOTES module
#
# Author: Stefan Schliebs
# Created: 2017-07-31
###########################################################


# Module server function
notesModule <- function(input, output, session, conf = NULL, constants = NULL) {
  
  
  # Initialisation ----------------------------------------------------------
  
  # obtain namespace
  ns <- session$ns
  
  
  # Data  ---------------------------------------------------------------------
  
  # load all data
  d.ufo <- reactive(read_rds("data/ufo-text.rds"))
  
  # filter data according to user input
  d.ufo_filtered <- reactive({
    req(input$year, input$continent, input$shape)
    
    d.ufo() %>%
      filter(
        year >= input$year[1], year <= input$year[2],   # Year filter
        continent %in% input$continent,                 # Continent
        shape %in% input$shape                          # Shape filter
      )
  })
  
  
  # Filter UI elements ------------------------------------------------------
  
  make_filter_ui_element <- function(variable, ui_id, ui_label) {
    # use dplyr's new quotation feature to obtain column name
    variable <- enquo(variable)
    
    # build list of choices for picker element
    choice_list <- d.ufo() %>% 
      count(!!variable, sort = TRUE) %>% 
      na.omit()
    
    # create picker element
    pickerInput(
      inputId = ui_id, 
      label = ui_label, 
      choices = choice_list %>% pull(!!variable), 
      selected = choice_list %>% pull(!!variable),
      choicesOpt = list(subtext = sprintf("(%s records)", format(choice_list$n, big.mark = ","))),
      options = list(
        `actions-box` = TRUE, 
        `live-search` = TRUE, 
        `live-search-placeholder` = "Type to search",
        `selected-text-format` = "count > 5"), 
      multiple = TRUE)
  }
  
  output$filter_continent <- renderUI({
    make_filter_ui_element(continent, ns("continent"), "Select continent")
  })  
  
  output$filter_shape <- renderUI({
    make_filter_ui_element(shape, ns("shape"), "Select UFO shape")
  })  
  
  
  # Wordcloud -----------------------------------------------------------------
  
  output$wordcloud <- renderD3wordcloud({
    d <- d.ufo_filtered() %>% 
      count(word, sort = TRUE) %>% 
      head(n = 100)
    
    d3wordcloud(d$word, d$n)
  })
  
}


