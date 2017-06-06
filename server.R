source('global.R')

shinyServer(function(input, output, session) {

  data <- reactive({
    inFile <- input$file

    if (is.null(inFile)) {
      return(NULL)
    }

    read.csv(inFile$datapath, header = input$header,
      sep = input$sep, quote = input$quote)
  })

  output$plot <- renderTable({

    inFile <- input$file

    if (is.null(inFile)) {
      return(NULL)
    }

    data()
  })

  output$outputColumnControls <- renderUI({
    colNames <- colnames(data())
    colNames <- colNames[!colNames %in% c('temp', 'precip')] # remove temp and precip columns, so we only have output columns
    selectInput('outputColumns', 'Display Variable', colNames)
  })

  observe({
    if (input$scaleType=='binary') {
      shinyjs::enable("binaryThreshold")
      shinyjs::disable("midpoint")
    }
    else {
      shinyjs::disable("binaryThreshold")
      shinyjs::enable("midpoint")
    }
  })
})
