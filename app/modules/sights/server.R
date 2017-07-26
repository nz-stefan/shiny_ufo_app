###########################################################
# Server logic for the SIGHTS module
#
# Author: Stefan Schliebs
# Created: 13 Feb 2017
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
    d.ufo() %>% 
      filter(
        year >= input$year[1], year <= input$year[2],   # Year filter
        country %in% input$country,                     # Country filter
        shape %in% input$shape                          # Shape filter
      )
    
  })
  
  
  # Filter UI elements ------------------------------------------------------

  output$filter_country <- renderUI({
    country_list <- d.ufo() %>% 
      distinct(country) %>% 
      na.omit() %>% 
      arrange(country) %>% 
      pull(country)

    pickerInput(
      inputId = ns("country"), 
      label = "Select countries", 
      choices = country_list, 
      selected = country_list,
      options = list(`actions-box` = TRUE), 
      multiple = TRUE)
  })  
  
  output$filter_shape <- renderUI({
    shape_list <- d.ufo() %>% 
      distinct(shape) %>% 
      na.omit() %>% 
      arrange(shape) %>% 
      pull(shape)
    
    pickerInput(
      inputId = ns("shape"), 
      label = "Select UFO shape", 
      choices = shape_list,
      selected = shape_list,
      options = list(`actions-box` = TRUE), 
      multiple = TRUE)
  })  
  
  # Map ---------------------------------------------------------------------

  output$map <- renderLeaflet({
    leaflet(data = d.ufo_filtered()) %>% 
      clearMarkerClusters() %>% 
      addTiles() %>% 
      addMarkers(lng = ~longitude, lat = ~latitude, popup = ~ html_label, clusterOptions = markerClusterOptions())
  })
  

  # Time series plots -------------------------------------------------------
  
  output$date_plot_ui <- renderUI({
    if(input$table_view) {
      dataTableOutput(ns("date_plot_table"), height = 400) %>% withSpinner(type = 3, color.background = "white")
    } else {
      highchartOutput(ns("date_plot"), height = 250) %>% withSpinner(type = 3, color.background = "white")
    }
  })
  
  output$date_plot_table <- renderDataTable({
    req(nrow(d.ufo_filtered()) > 0)   # at least one data record required for plotting
    
    # aggregate data
    group_var <- input$date_plot_dimension
    group_var_pretty <- gsub(pattern = "_", replacement = " ", group_var)
    d <- d.ufo_filtered() %>% 
      count(.data[[group_var]]) %>% 
      set_names(c(group_var_pretty, "counts")) 
    
    # specify data table options
    dt_options <- list(
      pageLength = 10,
      lengthChange = FALSE,
      searching = FALSE,
      pagingType = "simple_numbers",
      autoWidth = TRUE)
    
    # convert to data table
    df_dt <- d %>% 
      datatable(dt_options, rownames= FALSE, escape = FALSE) %>% 
      formatStyle(
        2,
        background = styleColorBar(c(min(d$counts), 1.01 * max(d$counts)), '#63B8FF'),
        backgroundSize = '100% 90%',
        backgroundRepeat = 'no-repeat',
        backgroundPosition = 'center'
      )
    
    df_dt
  })
  
  output$date_plot <- renderHighchart({
    req(nrow(d.ufo_filtered()) > 0)   # at least one data record required for plotting
    
    # aggregate data
    group_var <- input$date_plot_dimension
    d <- d.ufo_filtered() %>% 
      count(.data[[group_var]])
    
    # determine plot type
    plot_type <- switch(
      input$date_plot_dimension,
      year = "area",
      month = "area",
      day_of_week = "column",
      hour_of_day = "column"
    )
    
    # plot chart
    group_var_pretty <- gsub(pattern = "_", replacement = " ", group_var)
    hchart(d, plot_type, hcaes_string(x = "group_var", y = "n")) %>% 
      hc_yAxis(title = list(text = "")) %>% 
      hc_xAxis(title = list(text = group_var_pretty)) %>% 
      hc_title(text = paste0("Number of observations by ", group_var_pretty)) %>% 
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
    hchart(d, "column", hcaes(x = shape, y = n)) %>% 
      hc_yAxis(title = list(text = "")) %>% 
      hc_xAxis(title = list(text = "")) %>% 
      hc_title(text = "Top 10 UFO shapes") %>% 
      hc_add_theme(hc_app_theme())
  })
  
  output$summary_country <- renderHighchart({
    req(nrow(d.ufo_filtered()) > 0)   # at least one data record required for plotting
    
    # aggregate data
    d <- d.ufo_filtered() %>% 
      count(country, sort = TRUE) %>% 
      head(n = 10)
    
    # plot chart  
    hchart(d, "column", hcaes(x = country, y = n)) %>% 
      hc_yAxis(title = list(text = "")) %>% 
      hc_xAxis(title = list(text = "")) %>% 
      hc_title(text = "Top 10 countries") %>% 
      hc_add_theme(hc_app_theme())
  })
  
  output$summary_duration <- renderHighchart({
    req(nrow(d.ufo_filtered()) > 0)   # at least one data record required for plotting
    
    # compute density
    d <- d.ufo_filtered() %>% 
      filter(duration < 3600) %>% 
      pull(duration) %>% 
      na.omit() %>% 
      density()
    
    # plot chart  
    hcdensity(d) %>% 
      hc_yAxis(title = list(text = "")) %>% 
      hc_xAxis(title = list(text = "duration (in sec)")) %>% 
      hc_title(text = "Distribution of sight duration") %>% 
      hc_add_theme(hc_app_theme())
  })
}




