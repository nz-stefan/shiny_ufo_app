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
      if (input$tabs == "start") {
        rintrojs::introjs(session, options = list(
          steps = startModuleHelp("start_module")
        ))
      } else if (input$tabs == "notes") {
        rintrojs::introjs(session, options = list(
          steps = notesModuleHelp("notes_module")
        ))
      } else if (input$tabs == "sights") {
        rintrojs::introjs(session, options = list(
          steps = sightsModuleHelp("sights_module")
        ))
      }
    })
  })
