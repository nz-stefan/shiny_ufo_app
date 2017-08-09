###########################################################
# Server logic for the SIGHTS module
#
# Author: Stefan Schliebs
# Created: 2017-07-25
###########################################################


# Module server function
sightsModule <- function(input, output, session, conf = NULL, constants = NULL) {
  

  # Initialisation ----------------------------------------------------------

  # obtain namespace
  ns <- session$ns
  

  # Data  -------------------------------------------------------------------

  # load all data  
  d.ufo <- reactive(read_rds("data/ufo-cleaned.rds"))

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
  
  d.ufo_aggregated <- reactive({
    group_var <- input$date_plot_dimension
    
    # aggregate data according to selected dimension
    switch(input$date_plot_column,
      "obs_total" = 
        d.ufo_filtered() %>% 
        count(.data[[group_var]]) %>% 
        mutate(split_var = "Counts"),
      "obs_by_continent" = 
        d.ufo_filtered() %>% 
        count(.data[[group_var]], .data[["continent"]]) %>% 
        rename(split_var = continent)
    ) %>% 
      select(group_var, split_var, n)
  })
  
  
  # Filter UI elements ------------------------------------------------------

  output$filter_continent <- renderUI({
    d.ufo() %>% 
      make_filter_ui_element(continent, ns("continent"), "Select continent")
  })
  
  output$filter_shape <- renderUI({
    d.ufo() %>% 
      make_filter_ui_element(shape, ns("shape"), "Select UFO shape")
  })
  
  
  # Map ---------------------------------------------------------------------

  # plot empty map and use observe() to handle map changes
  output$map <- renderLeaflet({
    leaflet(
      # because map control's z-index is buggy, switch it off
      options = leafletOptions(zoomControl = FALSE, attributionControl = FALSE)  
    ) %>% 
      addTiles()
  })
  
  # handle map changes
  observe({
    req(nrow(d.ufo_filtered()) > 0)
    
    d <- d.ufo_filtered()
    
    # limit the number of records shown in the map for performance reasons
    MAX_RECORDS <- 10000
    formatted_max_record = format(MAX_RECORDS, big.mark = ",")
    
    if(nrow(d) > MAX_RECORDS) {
      d <- sample_n(d, MAX_RECORDS)
      sendSweetAlert(
        messageId = ns("msg_too_many_items"),
        title = "Too many records",
        text = sprintf(
          "There are more than %s records to show on the map. Use the filter to reduce
          the number of sightings. Showing %s randomly selected records on the map for now.",
          formatted_max_record, formatted_max_record),
        type = "warning",
        html = TRUE
      )
    }
    
    # create the map
    leafletProxy(ns("map"), data = d) %>% 
      clearMarkerClusters() %>%
      clearMarkers() %>% 
      addMarkers(lng = ~longitude, lat = ~latitude, popup = ~ html_label, clusterOptions = markerClusterOptions()) %>% 
      fitBounds(min(d$longitude), min(d$latitude), max(d$longitude), max(d$latitude))
  })
  

  # Time series table ---------------------------------------------------------
  
  output$date_plot_table <- renderDataTable({
    req(nrow(d.ufo_filtered()) > 0)   # at least one data record required for plotting
    
    # specify data table options
    dt_options <- list(
      pageLength = 10,
      lengthChange = FALSE,
      searching = FALSE,
      pagingType = "simple_numbers",
      autoWidth = TRUE)
    
    # compute min and max counts for setting length of cell color bar
    min_counts <- min(d.ufo_aggregated()$n)
    max_counts <- max(d.ufo_aggregated()$n)
    
    # clean up column names before converting to data table
    d <- d.ufo_aggregated() %>% 
      rename(time = group_var, location = split_var, counts = n)
    
    # remove non-variate columns
    if(n_distinct(d$location) == 1) {
      d <- d %>% select(-location)
    }
    
    # convert to data table
    d %>% 
      datatable(dt_options, rownames = FALSE, escape = FALSE) %>% 
      formatStyle(
        ncol(d),
        background = styleColorBar(c(min_counts, 1.01 * max_counts), '#63B8FF'),
        backgroundSize = '100% 90%',
        backgroundRepeat = 'no-repeat',
        backgroundPosition = 'center'
      )
  })
  

  # Time series plots -------------------------------------------------------
  
  output$date_plot_ui <- renderUI({
    if(input$table_view == "table") {
      div(
        dataTableOutput(ns("date_plot_table"), height = 400) %>% withSpinner(type = 3, color.background = "white"),
        style = "margin-bottom: 60px"
      )
      
    } else {
      highchartOutput(ns("date_plot"), height = 250) %>% withSpinner(type = 3, color.background = "white")
    }
  })
  
  output$date_plot <- renderHighchart({
    req(nrow(d.ufo_filtered()) > 0)   # at least one data record required for plotting
    
    # determine plot type
    plot_type <- switch(
      input$date_plot_dimension,
      year = "area",
      month = "area",
      day_of_week = "column",
      hour_of_day = "column"
    )
    
    # plot chart
    group_var_pretty <- gsub(pattern = "_", replacement = " ", input$date_plot_dimension)
    hchart(d.ufo_aggregated(), plot_type, hcaes(x = group_var, y = n, group = split_var)) %>% 
      hc_yAxis(title = list(text = "")) %>% 
      hc_xAxis(title = list(text = NULL), allowDecimals = FALSE) %>%
      hc_title(text = paste0("Number of observations by ", group_var_pretty)) %>% 
      hc_plotOptions(
        area = list(stacking = "normal"),
        column = list(stacking = "normal"),
        series = list(color = if(input$date_plot_column == "obs_total") "#109618")
      ) %>% 
      hc_tooltip(shared = TRUE) %>% 
      hc_add_theme(hc_app_theme())
  })
  

  # Summary plots -----------------------------------------------------------
  
  output$summary_shape <- renderHighchart({
    req(nrow(d.ufo_filtered()) > 0)   # at least one data record required for plotting

    # aggregate data
    d <- d.ufo_filtered() %>% 
      count(shape, sort = TRUE) %>% 
      head(n = 10)

    # plot chart  
    hchart(d, "bar", hcaes(x = shape, y = n)) %>% 
      hc_yAxis(title = list(text = "")) %>% 
      hc_xAxis(title = list(text = "")) %>% 
      hc_title(text = "Top 10 UFO shapes") %>% 
      hc_plotOptions(
        series = list(color = "#0099C6"),
        bar = list(dataLabels = list(enabled = TRUE))
      ) %>% 
      hc_add_theme(
        hc_theme_merge(
          hc_app_theme(),
          hc_theme(yAxis = list(labels = list(enabled = FALSE)))
        )
      )
  })
  
  output$summary_country <- renderHighchart({
    req(nrow(d.ufo_filtered()) > 0)   # at least one data record required for plotting
    
    # aggregate data
    d <- d.ufo_filtered() %>% 
      count(country_clean, sort = TRUE) %>% 
      head(n = 10)
    
    # plot chart  
    hchart(d, "bar", hcaes(x = country_clean, y = n)) %>% 
      hc_yAxis(title = list(text = "")) %>% 
      hc_xAxis(title = list(text = "")) %>% 
      hc_title(text = "Top 10 countries") %>% 
      hc_plotOptions(
        series = list(color = "#990099"),
        bar = list(dataLabels = list(enabled = TRUE))
      ) %>% 
      hc_add_theme(
        hc_theme_merge(
          hc_app_theme(),
          hc_theme(yAxis = list(labels = list(enabled = FALSE)))
        )
      )
  })
  
  output$summary_duration <- renderHighchart({
    req(nrow(d.ufo_filtered()) > 0)   # at least one data record required for plotting
    
    # compute density
    d <- d.ufo_filtered() %>% 
      filter(duration < 3600) %>% 
      mutate(duration_minutes = duration / 60) %>% 
      pull(duration_minutes) %>% 
      na.omit() %>% 
      density()
    
    # plot chart  
    hcdensity(d) %>% 
      hc_yAxis(visible = F) %>% 
      hc_xAxis(title = list(text = "minutes"), min = 0) %>% 
      hc_title(text = "Sight duration") %>% 
      hc_plotOptions(series = list(color = "#FF9900")) %>% 
      hc_add_theme(hc_app_theme())
  })


  # Info boxes ----------------------------------------------------------------
  
  output$total_sightings <- renderInfoBox({
    infoBox(
      title = "Total Sightings", subtitle = "records",
      value = nrow(d.ufo_filtered())%>% format(big.mark = ","), 
      icon = icon("space-shuttle"),
      color = "green")
  })
  
  output$total_duration <- renderInfoBox({
    infoBox(
      title = "Total Duration", subtitle = "hours",
      value = round(sum(d.ufo_filtered()$duration, na.rm = T) / 3600) %>% format(big.mark = ","), 
      icon = icon("clock-o"),
      color = "orange")
  })
  
  output$total_countries <- renderInfoBox({
    infoBox(
      title = "Location", subtitle = "countries",
      value = n_distinct(d.ufo_filtered()$country_clean) %>% format(big.mark = ","), 
      icon = icon("globe"),
      color = "purple")
  })
}
