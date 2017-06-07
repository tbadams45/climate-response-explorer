source('global.R')

# PACKAGE & DATA SOURCES -------------------------------------------------------
shinyUI(fluidPage(
  useShinyjs(),
  titlePanel('Climate Response Explorer'),
  sidebarLayout(
    sidebarPanel(
    #box(title = strong("Settings"), width=4, status="primary",
        p("Upload a CSV. Temperature column should be called 'temp', and precipitation should be 'precip'. You can have any number of columns with output variables."),
        fileInput('file', 'Choose file to upload',
          accept = c(
            'text/csv',
            'text/comma-separated-values',
            'text/tab-separated-values',
            'text/plain',
            '.csv',
            '.tsv'
          )
        ),
        actionButton('useDemoData', "Use demo data instead"),
        checkboxInput('fileOpt', "Show advanced file options", TRUE),
        tags$hr(),
        conditionalPanel(
          condition = 'input.fileOpt == true',
          checkboxInput('header', 'Header', TRUE),
          radioButtons('sep', 'Separator',
            c(Comma=',',
              Semicolon=';',
              Tab='\t'),
            ','),
          radioButtons('quote', 'Quote',
            c(None='',
              'Double Quote'='"',
              'Single Quote'="'"),
            '"'),
          tags$hr()
        ), # conditionalPanel close

        uiOutput('outputColumnControls'),
        uiOutput('rangeControls'),
        uiOutput('scaleOption'),
        uiOutput('midpointAndThresholdControls'),
        uiOutput('ascendingOption'),
        uiOutput('axisTitleControls'),
        uiOutput('saveButton')
    ), # close box

    mainPanel(
      plotOutput('plot')
    )
  )
))
