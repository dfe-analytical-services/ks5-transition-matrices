# -----------------------------------------------------------------------------------------------------------------------------
# ---- ui.R ----
# Dictates what will be shown within the app and where to find the data to fill it
# -----------------------------------------------------------------------------------------------------------------------------


#source('02_tm-tool.R')

ui = shinyUI(
  dashboardPage(
    dashboardHeader(title = '16-18 Transition Matrices',
                    titleWidth = 350
    ),
    
    dashboardSidebar(
      width =350,
      
      sidebarMenu(
        menuItem('Information', icon = icon('info'), tabName = 'info'),
        menuItem('Number of Pupils', icon = icon('hashtag'), tabName = 'number'),
        menuItem('Percentage of Pupils', icon = icon('percent'), tabName = 'percent')
      ),
      br(),
      br(),
      (h4(HTML('&nbsp;'),('Transition matrices options:'))),
      (h5(HTML('&nbsp;'),('1. Select a Qualification'))),
      selectInput('qual_select',
                  label = NULL,
                  list(Qualifications = sort(unique(lookup$`Qualification name`))),
                  selected = 'Applied GCE AS level'),
      (h5(HTML('&nbsp;'),('2. Select a Subject'))),
      selectInput('subj_select',
                  label = NULL,
                  list(Subjects = sort(unique(lookup$`Subject name`)))),
      (h5(HTML('&nbsp;'),('3. Select a Size'))),
      selectInput('size_select', 
                  label = NULL, 
                  list(Sizes = sort(lookup$ASIZE))),
      
      br(),
      br(),
      br(),
      downloadButton('tm_data_download_numbers', 'Download Raw Number Data'),
      br(),
      br(),
      downloadButton('tm_data_download_percentage', 'Download Raw Percentage Data')
      
      # sidebarMenu(
      #   br(),
      #   div(style='display:inline; font-size: 30px',menuItem('Number of Pupils', icon = icon('hashtag'), tabName = 'number')),
      #   br(),
      #   div(style='display:inline; font-size: 30px',menuItem('Percentage of Pupils', icon = icon('percent'), tabName = 'percent'))
      # )
    ),
    
    dashboardBody(
      ##    tags$head( 
      ##      tags$style(HTML(".main-sidebar { font-size: 20px; }")) #change the font size to 20
      ##    ),
      
      tags$style(type="text/css",
                 ".shiny-output-error { visibility: hidden; }",
                 ".shiny-output-error:before { visibility: hidden; }"
      ),
      tabItems(
        
        # Info tab
        tabItem('info',
                br(),
                h2('Information'),
                br(),
                tags$style(HTML("

                    .box.box-solid.box-primary>.box-header {
                    color:#fff;
                    background:#407291
                    }

                    .box.box-solid.box-primary{
                    border-bottom-color:#407291;
                    border-left-color:#407291;
                    border-right-color:#407291;
                    border-top-color:#407291;
                    background:#ffffff
                    }

                    ")),
                
                fluidRow(
                  box(width = 12, status = "primary", solidHeader = TRUE, 
                      'Transition matrices are a useful tool to help visualise the 
                      progression of pupils aged 16-18 from key stage 4 (KS4) to key 
                      stage 5 (KS5).',
                      br(),
                      br(),
                      'To use the transition matrices please select a qualification, subject and subject size from the dropdown boxes
                      found in the left panel. Use the Number of Pupils, and Percentage of Pupils tabs on the left to view
                      the respective tables. A graphical representaion of the percentage data can also be viewed within the 
                      Percentage of Pupils tab, and an additional dropdown box is available to select the required prior
                      attainment band. The tabular data from each table can be downloaded in csv format using the download 
                      button on each page.'
                  )
                ),
                br(),
                fluidRow(
                  box(width = 12, title = 'Example', status = "primary", solidHeader = TRUE,
                      'Below is an example transition matrix. It shows the 
                      national attainment of GCE A level mathematics students at 
                      KS5 based on their average KS4 attainment.',
                      br(),
                      
                      paste0('The highlighted cell shows the number of students with an average prior
                      attainment between 5 and 6 at KS4 who achieved a C in GCE A level 
                      mathematics was ', example_value, '.'),
                      br(),
                      br(),
                      DT::dataTableOutput('example_table'),
                      br()
                  )
                ),
                br()
        ),
        
        # Number tab
        tabItem('number',
                br(),
                h2('Number of students per KS4 attainment band for selected KS5 options'),
                DT::dataTableOutput('number_table'),
                br(),
                downloadButton('tm_data_download_tab_1', 'Download'),
                br()
        ),
        
        # Percentage tab
        tabItem('percent',
                br(),
                h2('Percentage of students per KS4 attainment band for selected KS5 options'),
                br(),
                dataTableOutput('percentage_table'),
                ##    formattableOutput('percentage_table'),
                br(),
                plotOutput('percentage_chart', height = '15cm'),
                selectInput('chart_band', 
                            label = 'Select a KS4 prior attainment band to display in the plot', 
                            list(bands = sort(grade_boundaries))),
                br(),
                downloadButton('tm_data_download_tab_2', 'Download'),
                br()
        )
      )
    )
  )
)
