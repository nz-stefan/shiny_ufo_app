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
        continent %in% input$continent,                 # Continent
        # country_clean %in% input$country,               # Country filter
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
  
  
  # Map ---------------------------------------------------------------------

  output$map <- renderLeaflet({
    d <- d.ufo_filtered()

    # limit the number of records shown in the map for performance reasons
    MAX_RECORDS <- 20000
    if(nrow(d) > MAX_RECORDS) {
      d <- sample_n(d, MAX_RECORDS)
      sendSweetAlert(
        messageId = ns("msg_too_many_items"), 
        title = "Too many records", 
        text = sprintf(
          "There are more than %d records to show on the map. Use the filter to reduce
          the number of sightings. Showing %d randomly selected records on the map for now.", 
          MAX_RECORDS, MAX_RECORDS), 
        type = "warning",
        html = TRUE
      )
      
    }
    
    leaflet(
        data = d,
        options = leafletOptions(zoomControl = FALSE, attributionControl = FALSE)
      ) %>% 
      clearMarkerClusters() %>% 
      addTiles() %>% 
      addMarkers(lng = ~longitude, lat = ~latitude, popup = ~ html_label, clusterOptions = markerClusterOptions())
  })
  

  # Time series plots -------------------------------------------------------
  
  output$date_plot_ui <- renderUI({
    if(input$table_view == "table") {
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
    d <- switch(input$date_plot_column,
      "obs_total" = d.ufo_filtered() %>% 
        count(.data[[group_var]]) %>% 
        mutate(split_var = "Counts"),
      "obs_by_continent" = d.ufo_filtered() %>% 
        group_by(.data[[group_var]], .data[["continent"]]) %>% 
        summarise(n = n()) %>% 
        rename(split_var = continent)# %>% 
        # arrange(group_var, split_var)
    )
    
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
    hchart(d, plot_type, hcaes(x = group_var, y = n, group = split_var)) %>% 
      hc_yAxis(title = list(text = "")) %>% 
      hc_xAxis(title = list(text = NULL)) %>%
      hc_title(text = paste0("Number of observations by ", group_var_pretty)) %>% 
      hc_plotOptions(
        area = list(stacking = "normal"),
        column = list(stacking = "normal")
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
      hc_add_theme(hc_app_theme())
  })
  
  output$summary_country <- renderHighchart({
    req(nrow(d.ufo_filtered()) > 0)   # at least one data record required for plotting
    
    # aggregate data
    d <- d.ufo_filtered() %>% 
      count(iso, sort = TRUE) %>% 
      head(n = 10)
    
    # plot chart  
    hchart(d, "bar", hcaes(x = iso, y = n)) %>% 
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
      mutate(duration_minutes = duration / 60) %>% 
      pull(duration_minutes) %>% 
      na.omit() %>% 
      density()
    
    # plot chart  
    hcdensity(d) %>% 
      hc_yAxis(visible = F) %>% 
      hc_xAxis(title = list(text = "minutes")) %>% 
      hc_title(text = "Sight duration") %>% 
      hc_add_theme(hc_app_theme())
  })
}
