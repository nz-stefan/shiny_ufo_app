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
  
  # load all datasets
  d.ufo_notes <- reactive(read_rds("data/ufo-tidytext.rds"))

  # filter data according to user input
  d.notes_filtered <- reactive({
    req(input$year, input$continent, input$shape)
    
    d.ufo_notes() %>%
      filter(
        year >= input$year[1], year <= input$year[2],   # Year filter
        continent %in% input$continent,                 # Continent
        shape %in% input$shape                          # Shape filter
      )
  })
  
  
  # Filter UI elements ------------------------------------------------------

  output$filter_continent <- renderUI({
    d.ufo_notes() %>% 
      make_filter_ui_element(continent, ns("continent"), "Select continent")
  })

  output$filter_shape <- renderUI({
    d.ufo_notes() %>% 
      make_filter_ui_element(shape, ns("shape"), "Select UFO shape")
  })
  
  
  # Wordcloud -----------------------------------------------------------------
  
  output$wordcloud <- renderD3wordcloud({
    req(nrow(d.notes_filtered()) > 0)
    
    # filter by clicked sentiment
    d <- d.notes_filtered()
    if(!is.null(input$hcClicked)) {
      d <- d %>% filter(sentiment == input$hcClicked)
    }
    
    d <- d %>% 
      count(word, sort = TRUE) %>% 
      head(n = 100)
    
    # delete the canvas of current wordcloud because the widget re-uses previous canvas
    runjs(sprintf("$('#%s svg g').empty();", ns("wordcloud")))
    d3wordcloud(d$word, d$n, size.scale = "log")
  })
  
  
  # Sentiment counts --------------------------------------------------------
  
  output$sentiment_counts <- renderHighchart({
    req(nrow(d.notes_filtered()) > 0)

    # if no sentiment was clicked yet, select a default sentiment
    clicked <- if(!is.null(input$hcClicked)) input$hcClicked else "positive"

    # count UFO sightings by sentiment
    d <- d.notes_filtered() %>% 
      group_by(sentiment) %>%
      summarise(n = n_distinct(rec_id)) %>%
      arrange(desc(n)) %>% 
      na.omit() %>% 
      mutate(col = "#0099C6") %>% 
      mutate(col = ifelse(sentiment == clicked, "#FF9900", col))

    # define javascript callback function to respond to click events in the bar chart
    callback_func <- JS("function(event) {Shiny.onInputChange('notes_module-hcClicked', event.point.name);}")
    
    hchart(d, "bar", hcaes(x = sentiment, y = n, color = col)) %>% 
      hc_yAxis(title = list(text = ""), breaks = c(0, max(d$n))) %>% 
      hc_xAxis(title = list(text = "")) %>% 
      hc_title(text = "Distribution of sentiment") %>% 
      hc_subtitle(text = "Click on bar to filter by sentiment") %>% 
      hc_tooltip(enabled = FALSE) %>% 
      hc_plotOptions(
        series = list(color = "#990099"),
        bar = list(events = list(click = callback_func))  # add click event callback here
      ) %>% 
      hc_add_theme(
        hc_theme_merge(
          hc_app_theme(),
          hc_theme(yAxis = list(labels = list(enabled = FALSE)))
        )
      )
  })
}
