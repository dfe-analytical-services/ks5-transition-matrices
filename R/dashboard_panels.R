homepage_panel <- function() {
  tabPanel(
    "Homepage",
    gov_main_layout(
      gov_row(
        column(
          12,
          heading_text(
            "16 to 18 Transition Matrices",
            size = "l",
            level = 1
          )
        )
      ),

      ## Left panel -------------------------------------------------------
      layout_column_wrap(
        width = 0.5,
        bslib::card(
          bslib::card_header(
            heading_text("Contents", size = "m", level = 2)
          ),
          bslib::card_body(
            heading_text("Introduction", size = "s", level = 3),
            gov_text(
              "This app demonstrates the 16 to 18 Transition Matrices data."
            ),
            gov_text(
              "Transition matrices are a useful tool to help visualise the progression of pupils aged 16 to 18 from key stage 4
              (KS4) to key stage 5 (KS5)."
            ),
            gov_text(
              actionLink("link_to_app_content_tab", "16 to 18 Transition Matrices tool")
            ),
            gov_text(
              "A level and other 16 to 18 results data are now all available on the statistics platform, ",
              actionLink(
                "parent_publication",
                "Explore Education Statistics (EES)"
              )
            )
          )
        ),

        ## Right panel ------------------------------------------------------
        bslib::card(
          bslib::card_header(
            heading_text("Information", size = "m", level = 2)
          ),
          bslib::card_body(
            heading_text("Context and purpose", size = "s", level = 3),
            gov_text(
              "To use the 16 to 18 Transition Matrices tool click onto the 'Dashboard' tab found on the left panel. Please then
              select a report year (the year students finished 16 to 18 study), qualification, subject and subject size from the dropdown boxes.
              Use the 'Numbers data' and 'Percentage Data' options to switch the
              table view between number of students and percentage of students."
            ),
            gov_text("A graphical representaion of the percentage data can also be viewed when the 'Percentage Data' option has been selected,
              and an additional dropdown box is available to select the required KS4 prior attainment band."),
            gov_text("All underlying data can be downloaded in csv format using the download buttons at the bottom of the TM tool page.
              Smaller filtered tables, built within the dashboard, can also be downloaded in csv format using the
              download button also at the bottom of the TM tool page.")
          )
        )
      ),
      # ),

      ## Lower panel -------------------------------------------------------
      gov_row(
        column(
          12,
          bslib::card(
            bslib::card_header(
              heading_text("Example of using the TM tool", size = "m", level = 2)
            ),
            bslib::card_body(
              heading_text("Example", size = "s", level = 3),
              gov_text("Below is an example transition matrix. It shows the national attainment of
              GCE A level mathematics students at KS5 based on their average KS4 attainment."),
              gov_text("The highlighted cell shows the number of students with an average prior
                  attainment between 5 and 6 at KS4 who achieved a C in GCE A level
                  mathematics was ", example_value, "."),
              DT::dataTableOutput("example_table")
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
          width = 12,
          bslib::card(
            bslib::card_header(
              heading_text("16-18 English and maths progress by prior attainment matrix",
                size = "m",
                level = 2
              )
            ),
            bslib::card_body(
              # input selection --------------------------------------------------
              layout_column_wrap(
                width = 0.5,
                selectizeInput(
                  inputId = "ReportYr_select",
                  label = "1. Select a report year",
                  choices = unique(qual_lookup$ReportYr),
                  selected = max(qual_lookup$ReportYr)
                ),
                selectizeInput(
                  inputId = "qual_select",
                  label = "2. Select a qualification",
                  choices = unique(qual_lookup$Qual_Description),
                  # selected = "GCE A level"
                ),
                selectizeInput(
                  inputId = "subj_select",
                  label = "3. Select a subject",
                  choices = unique(qual_lookup$Subject),
                  # selected = "Mathematics"
                ),
                selectizeInput(
                  inputId = "size_select",
                  label = "4. Select a size",
                  choices = list(Sizes = sort(unique(qual_lookup$SIZE)))
                ),
                selectizeInput(
                  inputId = "grade_structure_select",
                  label = "5. Select a grade structure",
                  choices = list(GradeStructures = sort(unique(qual_lookup$gradeStructure)))
                )
              ),
              layout_column_wrap(
                width = 0.5,
                radioButtons(
                  inputId = "format",
                  label = "6. Select format of data: ",
                  choices = c("Numbers data", "Percentage data")
                )
              ),
              layout_column_wrap(
                width = 0.5,
                uiOutput("chart_band_appear")
              )
            )
          )
        ),
        gov_row(
          column(
            width = 12,
            bslib::card(
              bslib::card_body(
                htmlOutput("tm_title"),
                DT::dataTableOutput("tm_table") %>% withSpinner(color = "#1d70b8"),
                br(),
                conditionalPanel(
                  condition = "input.format == 'Percentage data'",
                  plotOutput(
                    "percentage_chart",
                    height = "15cm"
                  ) %>% withSpinner(color = "#1d70b8")
                )
              )
            )
          )
        ),
        gov_row(
          column(
            width = 12,
            bslib::card(
              bslib::card_header(
                heading_text("Download the underlying data for this dashboard:",
                  size = "m",
                  level = 2
                )
              ),
              column(
                width = 6,
                bslib::card_body(
                  downloadButton(
                    outputId = "tm_data_download_numbers",
                    label = "Download (all student numbers data)",
                    icon = shiny::icon("download"),
                    class = "downloadButton"
                  ),
                  br(),
                  downloadButton(
                    outputId = "tm_data_download_percentage",
                    label = "Download (all student percentage data)",
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
  )
}
