###########################################################
# Global server logic of the application
# 
# Author: Stefan Schliebs
# Created: 2017-07-25
###########################################################


shinyServer(
  function(input, output, session) {

    # load configuration from either URL token or getOption("dashboard-tenant")
    # conf <- reactive(load_configuration(session))
    
    # load constants
    # constants <- list(
    #   CAMPAIGN = reactive(load_table("campaign"))
    # )
    
    # call modules to add functionality of dashboard tabs
    callModule(sightsModule, "sights_module")
    callModule(notesModule, "notes_module")
    # callModule(salesModule, "sales_module", conf, constants)
    
    observeEvent(input$intro, {
      if (input$tabs == "notes") {
        rintrojs::introjs(session, options = list(
          steps = data.frame(element = c(NA, "#one"),
                             intro = c("This first step is the same regardless of the tab, but the second step is different",
                                       "This is the first tab"))
        ))
      } else if (input$tabs == "sights") {
        rintrojs::introjs(session, options = list(
          steps = data.frame(element = c(NA, "#two"),
                             intro = c("This first step is the same regardless of the tab, but the second step is different",
                                       "This is the second tab"))
        ))
      }
    })
  })
