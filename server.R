source('global.R')

shinyServer(function(input, output, session) {
  data <- reactive({
    # temp <- input$useDemoData
    input$file

    # if(temp > actionButtonVal()) {
    #   csv <- read.csv('data/stresstest_ffd.csv', header = TRUE,
    #            sep = ',', quote = '"')
    #   actionButtonVal(temp)
    #   updateCheckboxInput(session, 'fileOpt', value = FALSE)
    # }
    # else {
      inFile <- input$file

      if (is.null(inFile)) {
        return(NULL)
      }

      csv <- read.csv(inFile$datapath, header = input$header,
        sep = input$sep, quote = input$quote)

      updateCheckboxInput(session, 'fileOpt', value = FALSE)
    # }
    csv
  })


  # data <- eventReactive(input$useDemoData,{
  #    csv <- read.csv('data/stresstest_ffd.csv', header = TRUE,
  #      sep = ',', quote = '"')
  #    head(csv)
  #    csv
  # })

  plot <- reactive({
    input$useDemoData # take dependency on button
    inFile <- input$file

    if (is.null(input$outputColumns) ||
        #is.null(input$binaryThreshold) ||
        is.null(input$isContinuousScale) ||
        #is.null(input$midpoint) ||
        is.null(input$rangeMin) ||
        is.null(input$midOrThreshold) ||
        is.null(input$ascending) ||
        is.null(input$rangeMax)) {
      return(NULL)
    }

    temp_plot <- climate_heatmap(
      data(),
      metric = input$outputColumns,
      threshold = as.numeric(input$midOrThreshold),
      binary = !as.logical(input$isContinuousScale),
      ascending = input$ascending,
      midpoint = input$midOrThreshold,
      range = c(input$rangeMin, input$rangeMax)
    )

    if(input$xAxisUnits == "%") {
      xLab <- paste(input$xAxisTitle, " (%)")
    } else {
      xLab <- paste(input$xAxisTitle, " (°", input$xAxisUnits, ")", sep = '')
    }

    yLab <- paste(input$yAxisTitle, " (", input$yAxisUnits, ")", sep = '')

    temp_plot +
      labs(x = xLab, y = yLab) +
      theme(text = element_text(size = input$textSize))
  })

  output$plot <- renderPlot({
    plot()
  })

  output$outputColumnControls <- renderUI({
    if(is.null(data())) {
      return(NULL)
    }
    colNames <- colnames(data())
    colNames <- colNames[!colNames %in% c('temp', 'precip')] # remove temp and precip columns, so we only have output columns
    selectInput('outputColumns', 'Display Variable', colNames)
  })

  output$rangeControls <- renderUI({
    if(is.null(input$outputColumns)) {
      return(NULL)
    }
    selected <- data()[input$outputColumns]

    tagList(
      numericInput('rangeMin', 'Range Minimum', value = floor(min(selected))),
      numericInput('rangeMax', 'Range Maximum', value = ceiling(max(selected)))
    )
  })

  output$scaleOption <- renderUI({
    if(is.null(data())) {
      return(NULL)
    }
    radioButtons('isContinuousScale',
      'Evaluation Type',
      c('Continuous' = TRUE, 'Binary' = FALSE),
      selected = TRUE,
      inline = TRUE)
  })

  output$midpointAndThresholdControls <- renderUI({
    if(is.null(data()) ||
       is.null(input$rangeMin) ||
       is.null(input$rangeMax)) {
      return(NULL)
    }

    if(input$isContinuousScale == TRUE) {
      sliderInput('midOrThreshold', 'Midpoint', min = input$rangeMin, max = input$rangeMax,
        value = (input$rangeMax + input$rangeMin) / 2, round = TRUE)
    }
    else {
      sliderInput('midOrThreshold', 'Threshold', min = input$rangeMin, max = input$rangeMax,
        value = (input$rangeMax + input$rangeMin) / 2, round = TRUE)
    }
  })

  output$saveButton <- renderUI({
    if(is.null(data())) {
      return(NULL)
    }
    actionButton('save', 'Save Plot')
  })

  output$ascendingOption <- renderUI({
    if(is.null(data())) {
      return(NULL)
    }
    checkboxInput('ascending', 'Ascending', value = TRUE)
  })

  output$axisTitleControls <- renderUI({
    if(is.null(data())) {
      return(NULL)
    }
    tagList(
      textInput('xAxisTitle', 'X Axis Name', value = 'Temperature Change'),
      selectInput('xAxisUnits', 'X Axis Units', choices = c("Fahrenheit" = "F", "Celsius" = "C", "%")),
      textInput('yAxisTitle', 'Y Axis Name', value = 'Precipitaton Change'),
      textInput('yAxisUnits', 'Y Axis Units', value = "%"),
      numericInput('textSize', 'Text Size', value = 20, min = 6, max = 100)
    )
  })

  observeEvent(input$save, {
    showModal(modalDialog(
      textInput('name', "Name (include file extension, pdf seems to work well)"),
      numericInput('width', 'Width (in inches)', value = 6, min = 1),
      numericInput('height', 'Height (in inches)', value = 5, min = 1),
      numericInput('dpi', 'DPI (600-1200 for journal quality)', value = 600, min = 100),
      actionButton('saveConfirm', 'Save Plot'),
      title = "Plot Options",
      easyClose = TRUE
    ))
  })

  observeEvent(input$saveConfirm, {
    ggsave(
      input$name,
      plot(),
      width = input$width,
      height = input$height,
      dpi = input$dpi,
      units = 'in')
  })

})
