source('global.R')

shinyServer(function(input, output, session) {
  data <- reactive({

    inFile <- input$file

    if (is.null(inFile)) {
      return(NULL)
    }

    csv <- read.csv(inFile$datapath, header = input$header,
      sep = input$sep, quote = input$quote)

    updateCheckboxInput(session, 'fileOpt', value = FALSE)
    csv
  })

  plot <- reactive({
    inFile <- input$file

    if (is.null(input$outputColumns) ||
        is.null(input$isContinuousScale) ||
        is.null(input$rangeMin) ||
        is.null(input$ascending) ||
        is.null(input$bins) ||
        is.null(input$toPercentX) ||
        is.null(input$toPercentY) ||
        is.null(input$rangeMax)) {
      return(NULL)
    }

    if(input$isContinuousScale == TRUE) {
      bins <- as.numeric(unlist(strsplit(input$bins, split=",")))

      if(input$colors != ''){
        colors <- unlist(strsplit(input$colors, split=","))
      } else {
        colors <- NULL
      }

      temp_plot <- climate_heatmap_continuous(
        data(),
        metric = input$outputColumns,
        bins = bins,
        ascending = input$ascending,
        range = c(input$rangeMin, input$rangeMax),
        colors = colors,
        to_percent = c(input$toPercentX, input$toPercentY),
        z_axis_title = input$zAxisTitle
      )

    } else {
      if(input$colors != ''){
        colors <- unlist(strsplit(input$colors, split=","))
      } else {
        colors <- NULL
      }

      temp_plot <- climate_heatmap_binary(
        data(),
        metric = input$outputColumns,
        threshold = as.numeric(input$threshold),
        ascending = input$ascending,
        color_scale = colors,
        to_percent = c(input$toPercentX, input$toPercentY),
        z_axis_name = input$zAxisTitle
      )
    }

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
    if(is.null(input$outputColumns) ||
        input$isContinuousScale == FALSE) {
      return(NULL)
    }
    selected <- data()[input$outputColumns]

    tagList(
      numericInput('rangeMin', 'Range Minimum', value = floor(min(selected))),
      numericInput('rangeMax', 'Range Maximum', value = ceiling(max(selected)))
    )
  })

  output$scaleOption <- renderUI({
    if (is.null(data())) {
      return(NULL)
    }
    radioButtons('isContinuousScale',
      'Evaluation Type',
      c('Continuous' = TRUE, 'Binary' = FALSE),
      selected = TRUE,
      inline = TRUE)
  })

  output$evalTypeSpecificControls <- renderUI({
    if(is.null(data()) ||
       is.null(input$rangeMin) ||
       is.null(input$rangeMax)) {
      return(NULL)
    }

    if (input$isContinuousScale == TRUE) {
      tagList(
        textInput('bins', 'Bins (e.g. 7, or 20, 30, 40, 50 for bins [20,30], (30,40], (40,50])',
                    value = "7"),
        textInput('colors', 'Custom colors (e.g. #EF8A62,#F7F7F7,#67A9CF). Must equal number of bins',
                  value = '')
      )
    }
    else {
      selected <- data()[input$outputColumns]

      rangeMin <- floor(min(selected))
      rangeMax <- ceiling(max(selected))

      tagList(
        sliderInput('threshold', 'Threshold', min = rangeMin, max = rangeMax,
          value = (rangeMax + rangeMin) / 2, round = TRUE),
        textInput('colors', 'Custom colors (e.g. #2E2ECC,#CC2E2E). Must have 2 colors',
          value = '')
      )
    }
  })

  output$saveButton <- renderUI({
    if (is.null(data())) {
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

  output$formatAsPercentageControls <- renderUI({
    if(is.null(data())) {
      return(NULL)
    }
    tagList(
      checkboxInput('toPercentX', "Format temp as percentage change", value = FALSE),
      checkboxInput('toPercentY', "Format precip as percentage change", value = TRUE)
    )
  })

  output$titleControls <- renderUI({
    if(is.null(data())) {
      return(NULL)
    }
    tagList(
      textInput('xAxisTitle', 'X Axis Name', value = 'Temperature Change'),
      selectInput('xAxisUnits', 'X Axis Units', choices = c("Fahrenheit" = "F", "Celsius" = "C", "%")),
      textInput('yAxisTitle', 'Y Axis Name', value = 'Precipitaton Change'),
      textInput('yAxisUnits', 'Y Axis Units', value = "%"),
      numericInput('textSize', 'Text Size', value = 20, min = 6, max = 100),
      textInput('zAxisTitle', 'Z Axis Title', value = "Range")
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
