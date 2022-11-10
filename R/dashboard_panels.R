homepage_panel <- function() {
  tabPanel(
    "Homepage",
    gov_main_layout(
      gov_row(
        column(
          12,
          h1("16-18 Transition Matrices"),
          br(),
          br()
        ),
        
        ## Left panel -------------------------------------------------------
        
        column(
          6,
          div(
            div(
              class = "panel panel-info",
              div(
                class = "panel-heading",
                style = "color: white;font-size: 18px;font-style: bold; background-color: #1d70b8;",
                h2("Contents")
              ),
              div(
                class = "panel-body",
                tags$div(
                  h3("Introduction"),
                  p("This app demonstrates the 16-18 Transition Matrices data."),
                  p("Transition matrices are a useful tool to help visualise the 
                      progression of pupils aged 16-18 from key stage 4 (KS4) to key 
                      stage 5 (KS5)."),
                  p(actionLink("link_to_app_content_tab", "16-18 Transition Matrices tool")),
                  br(),
                  p("A level and other 16 to 18 results data are now all available on the statistics platform, ", 
                    a("Explore Education Statistics (EES)", 
                      href = "https://explore-education-statistics.service.gov.uk/find-statistics/a-level-and-other-16-to-18-results")),
                  br()
                )
              )
            )
          ),
        ),
        
        ## Right panel ------------------------------------------------------
        
        column(
          6,
          div(
            div(
              class = "panel panel-info",
              div(
                class = "panel-heading",
                style = "color: white;font-size: 18px;font-style: bold; background-color: #1d70b8;",
                h2("Information")
              ),
              div(
                class = "panel-body",
                h3("Context and purpose"),
                p("To use the 16-18 Transition Matrices tool click onto the '16-18 TM tool' tab found on the left panel. Please then
                select a qualification, subject and subject size from the dropdown boxes. 
                Use the 'Numbers data' and 'Percentage Data' options to switch the 
                table view between number of students and percentage of students."),
                br(),
                p("A graphical representaion of the percentage data can also be viewed when the 'Percentage Data' option has been selected,
                and an additional dropdown box is available to select the required KS4 prior attainment band."), 
                br(),
                p("All underlying data can be downloaded in csv format using the download buttons at the bottom of the TM tool page.
                Smaller filtered tables, built within the dashboard, can also be downloaded in csv format using the 
                download button also at the bottom of the TM tool page.")
              )
            )
          )
        ),
        
        ## Lower panel -------------------------------------------------------
        
        column(
          12,
          div(
            div(
              class = "panel panel-info",
              div(
                class = "panel-heading",
                style = "color: white;font-size: 18px;font-style: bold; background-color: #1d70b8;",
                h2("Example of using the TM tool")
              ),
              div(
                class = "panel-body",
                tags$div(
                  h3("Example"),
                  p("Below is an example transition matrix. It shows the national attainment of 
                  GCE A level mathematics students at KS5 based on their average KS4 attainment."),
                  p("The highlighted cell shows the number of students with an average prior
                      attainment between 5 and 6 at KS4 who achieved a C in GCE A level
                      mathematics was ", example_value, "."),
                  br(),
                  DT::dataTableOutput("example_table"),
                  br(),
                  br()
                )
              )
            )
          )
        )
      )
    )
  )
  
}


dashboard_panel <- function() {
  tabPanel(
    value = "dashboard",
    "Dashboard",
    
    gov_main_layout(
      gov_row(
        column(
          width=12,
          h1("16-18 Transition Matrices"),
          br(), 
          br(), 
        ),
        
        column(
          width=12,
          div(
            class = "well",
            style = "min-height: 100%; height: 100%; overflow-y: visible",
            gov_row(
              column(
                width = 6,
                selectizeInput(
                  inputId = "qual_select",
                  label = "1. Select a qualification",
                  choices = list(Qualifications = sort(unique(qual_lookup$Qual_Description))),
                  selected = "GCE A level"
                )
              ),
              
              column(
                width = 6,
                selectizeInput(
                  inputId = "subj_select",
                  label = "2. Select a subject",
                  choices = list(Subjects = sort(unique(qual_lookup$Subject))),
                  selected = "Mathematics"
                )
              ), 
              
              column(
                width = 6,
                selectizeInput(
                  inputId = "size_select",
                  label = "3. Select a size",
                  choices = list(Sizes = sort(qual_lookup$SIZE))
                )
              ),
              
              column(
                width = 6,
                selectizeInput(
                  inputId = "grade_structure_select",
                  label = "4. Select a grade structure",
                  choices = list(GradeStructures = sort(qual_lookup$gradeStructure))
                )
              ),
              
              column(
                width = 12,
                radioButtons(inputId="format", 
                             label="5. Select format of data: ", 
                             choices=c("Numbers data", "Percentage data")
                ),
                uiOutput("chart_band_appear")
              )
            )
          )
        ),
        
        
        
        
        column(
          width=12,
          gov_row(
            column(
              width = 12,
              br(),
              br(),
              htmlOutput("tm_title"),
              DT::dataTableOutput("tm_table") %>% withSpinner(color="#1d70b8")
              ),
            

            column(
              width=12,
              br(),
              br(),
              conditionalPanel(
                condition = "input.format == 'Percentage data'",
                plotOutput("percentage_chart", height = "15cm") %>% withSpinner(color="#1d70b8")
                ),
              br(),
              br()
              )
            )
          ),
        

        column(
          width=12,
          div(
            class = "well",
            style = "min-height: 100%; height: 100%; overflow-y: visible",
            gov_row(
              column(
                width = 12,
                paste("Download the underlying data for this dashboard:"), br(),
                downloadButton(
                  outputId = "tm_data_download_numbers",
                  label= "Download (all student numbers data)",
                  icon = shiny::icon("download"),
                  class = "downloadButton"
                ),
                br(),
                br()
              ),
              
              column(
                width = 12,
                downloadButton(
                  outputId = "tm_data_download_percentage",
                  label= "Download (all student percentage data)",
                  icon = shiny::icon("download"),
                  class = "downloadButton"
                )
              )
              
            )
          )
        )
      )
    )
  )
}