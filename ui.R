# -----------------------------------------------------------------------------------------------------------------------------
# ---- ui.R ----
# Dictates what will be shown within the app and where to find the data to fill it
# -----------------------------------------------------------------------------------------------------------------------------


ui = shinyUI(fluidPage(
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "dfe_shiny_gov_style.css")),

  
 # title = "16-18 Transition Matrices",
  
  dashboardPage(


    dashboardHeader(title = "16-18 Transition Matrices",
                    titleWidth = 350),
    
    
    dashboardSidebar(
      width =350,
      
      sidebarMenu(
        menuItem("Information", icon = icon("info"), tabName = "info"),
        menuItem("Transition Matrices", icon = icon("table"), tabName = "tm"),
        menuItem("Accessibility", icon = icon("user"), tabName = "accessibility")
      ),
      br(),
      br(),
      helpText("Choose a qualification, subject and size to view the transition matrices.",
               style = "margin: 5px 5px 5px 10px; "),
      br(),
      selectInput("qual_select",
                  label = "1. Select a Qualification",
                  list(Qualifications = sort(unique(lookup$`Qualification name`))),
                  selected = "GCE A level"),
      selectInput("subj_select",
                  label = "2. Select a Subject",
                  list(Subjects = sort(unique(lookup$`Subject name`)))),
      selectInput("size_select", 
                  label = "3. Select a Size", 
                  list(Sizes = sort(lookup$SIZE))),
      radioButtons(inputId="format", 
                   label="4. Select format of data: ", 
                   choices=c("Numbers data", "Percentage data")),
      br(),
      br(),
      downloadButton(outputId = "tm_data_download_numbers",
                     label = "Download (all student numbers data)",
                     style = "color: black; border-color: #fff; padding: 5px 14px 5px 14px; margin: 5px 5px 5px 10px; "),
      br(),
      br(),
      downloadButton(outputId = "tm_data_download_percentage", 
                     label = "Download (all student percentage data)",
                     style = "color: black; border-color: #fff; padding: 5px 14px 5px 14px; margin: 5px 5px 5px 10px; ")
    ),
    
    dashboardBody(
      
      tags$style(type="text/css",
                 ".shiny-output-error { visibility: hidden; }",
                 ".shiny-output-error:before { visibility: hidden; }"
      ),
      
      tags$head(tags$style(HTML(".skin-blue .main-header .logo {background-color: #0b0c0c;}"))),
      
      
      
      tabItems(
        
        # Info tab
        tabItem("info",
                br(),
                h2("Information"),
                br(),
                
                "Transition matrices are a useful tool to help visualise the 
                      progression of pupils aged 16-18 from key stage 4 (KS4) to key 
                      stage 5 (KS5).",
                br(),
                br(),
                "To use the transition matrices please select a qualification, subject and subject size from the dropdown boxes
                found in the left panel. Use the 'Numbers data' and 'Percentage Data' options, also on the left, to switch the 
                table view between number of students and percentage of students.",
                br(),
                "A graphical representaion of the percentage data can also be viewed when the 'Percentage Data' option has been selected,
                and an additional dropdown box is available to select the required KS4 prior attainment band.", 
                br(),
                "All underlying data can be downloaded in csv format using the download buttons on the left panel.
                Smaller filtered tables, built within the dashboard, can also be downloaded in csv format using the download button on the
                Transition Matrices page.",
                br(),
                br(),
                br(),
                h3("Transition Matrices Example"),
                "Below is an example transition matrix. It shows the national attainment of GCE A level mathematics students at 
                KS5 based on their average KS4 attainment.",
                br(),
                br(),
                paste0("The highlighted cell shows the number of students with an average prior
                      attainment between 5 and 6 at KS4 who achieved a C in GCE A level
                      mathematics was ", example_value, "."),
                br(),
                br(),
                DT::dataTableOutput("example_table"),
                br(),
                br()
        ),
        
        # TM tab
        tabItem("tm",
                br(),
                h2("16-18 Transition Matrices for academic year 2020/2021"),
                uiOutput("tm_title"),
            #    h2("Number of students per KS4 attainment band for selected KS5 options"),
                DT::dataTableOutput("tm_table"),
                br(),
                downloadButton("tm_data_download_filtered", "Download"),
                br(),
                br(),
                br(),
                plotOutput("percentage_chart", height = "15cm"),
                br(),
                uiOutput("chart_band_appear")
        ),
        
        
        # accessibility tab
        tabItem("accessibility",
                br(),
                accessibility_statement()
        )
      )
    )
  )
))


