source('global.R')

# PACKAGE & DATA SOURCES -------------------------------------------------------
shinyUI(fluidPage(
  useShinyjs(),
  titlePanel('Climate Response Explorer'),
  sidebarLayout(
    sidebarPanel(
    #box(title = strong("Settings"), width=4, status="primary",
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
        actionButton('use-demo-data', "Use demo data instead"),
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

        radioButtons('scaleType',
          'Evaluation Type',
          c('Continuous' = 'continuous', 'Binary' = 'binary'),
          selected = 'continuous',
          inline = TRUE),

        sliderInput('midpoint', 'Midpoint', min = 40, max = 100, value = 80, round = TRUE),
        sliderInput('binaryThreshold', 'Threshold', min = 40, max = 100, value = 80, round = TRUE)
    ), # close box

    mainPanel(
      tableOutput('plot')
    )
  )
))
