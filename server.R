# ---------------------------------------------------------
# This is the server file.
# Use it to create interactive elements like tables, charts and text for your app.
#
# Anything you create in the server file won't appear in your app until you call it in the UI file.
# This server script gives an example of a plot and value box that updates on slider input.
# There are many other elements you can add in too, and you can play around with their reactivity.
# The "outputs" section of the shiny cheatsheet has a few examples of render calls you can use:
# https://shiny.rstudio.com/images/shiny-cheatsheet.pdf
#
#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# ---------------------------------------------------------


server <- function(input, output, session) {
  # Loading screen ---------------------------------------------------------------------------
  # Call initial loading screen

  hide(id = "loading-content", anim = TRUE, animType = "fade")
  show("app-content")

  # Simple server stuff goes here ------------------------------------------------------------

  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Homepage tab ----
  # -----------------------------------------------------------------------------------------------------------------------------

  output$cookies_status <- dfeshiny::cookies_banner_server(
    input_cookies = reactive(input$cookies),
    google_analytics_key = google_analytics_key,
    parent_session = session
  )

  # Server logic for the panel, can be placed anywhere in server.R -------
  cookies_panel_server(
    input_cookies = reactive(input$cookies),
    google_analytics_key = google_analytics_key
  )

  # link to TM tool
  observeEvent(input$link_to_app_content_tab, {
    updateTabsetPanel(session, "navlistPanel", selected = "dashboard")
  })



  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Updates to drop down boxes ----
  # -----------------------------------------------------------------------------------------------------------------------------
  # The below code alters the options in the subject select drop down by only showing the corresponding subjects available
  # to the qualification that a user selects in the qualification select drop down
  # qualifications with only one subject, and subjects with multiple sizes require special formatting


  observe({
    updateSelectInput(session,
      inputId = "subj_select",
      label = NULL,
      choices <- qual_lookup %>%
        filter(ReportYr == input$ReportYr_select & Qual_Description == input$qual_select) %>%
        pull(Subject) %>%
        sort(.)
    )
  })



  # we need to identify which subjects have multiple sizes
  # use this output to update the size select drop down box below
  multiple_sizes <- qual_lookup %>%
    group_by(ReportYr, Qual_Description, SUBLEVNO, Subject, SUBJ) %>%
    count() %>%
    filter(n > 1) %>%
    mutate(qual_subj_combined = paste0(ReportYr, " - ", Qual_Description, " - ", Subject))
  # multiple_sizes



  observe({
    updateSelectInput(session,
      inputId = "size_select",
      label = NULL,
      if (paste0(input$ReportYr_select, " - ", input$qual_select, " - ", input$subj_select) %in% multiple_sizes$qual_subj_combined) {
        choices <- qual_lookup %>%
          filter(
            ReportYr == input$ReportYr_select,
            Qual_Description == input$qual_select,
            Subject == input$subj_select
          ) %>%
          select(SIZE) %>%
          arrange(SIZE)
      } else {
        choices <- qual_lookup %>%
          filter(
            ReportYr == input$ReportYr_select,
            Qual_Description == input$qual_select,
            Subject == input$subj_select
          ) %>%
          select(SIZE) %>%
          as.character()
      }
    )
  })




  # we need to identify which subject and sizes have multiple grade structures
  # use this output to update the grade select drop down box below
  multiple_gradestructures <- qual_lookup %>%
    group_by(ReportYr, Qual_Description, SUBLEVNO, Subject, SUBJ, SIZE) %>%
    count() %>%
    filter(n > 1) %>%
    mutate(qual_subj_size_combined = paste0(ReportYr, " - ", Qual_Description, " - ", Subject, " - ", SIZE))
  # multiple_gradestructures



  observe({
    updateSelectInput(session,
      inputId = "grade_structure_select",
      label = NULL,
      if (paste0(input$ReportYr_select, " - ", input$qual_select, " - ", input$subj_select, " - ", input$size_select) %in% multiple_gradestructures$qual_subj_size_combined) {
        choices <- qual_lookup %>%
          filter(
            ReportYr == input$ReportYr_select,
            Qual_Description == input$qual_select,
            Subject == input$subj_select,
            SIZE == input$size_select
          ) %>%
          select(gradeStructure) %>%
          arrange(gradeStructure)
      } else {
        choices <- qual_lookup %>%
          filter(
            ReportYr == input$ReportYr_select,
            Qual_Description == input$qual_select,
            Subject == input$subj_select,
            SIZE == input$size_select
          ) %>%
          select(gradeStructure) %>%
          as.character()
      }
    )
  })



  # only want the prior band drop down box to appear if the percentage data checkbox has been selected
  output$chart_band_appear <-
    renderUI({
      req(input$format == "Percentage data")
      selectInput("chart_band",
        label = tags$span(style = "color: white;", "7. Select a KS4 prior attainment band to display in the plot"),
        list(bands = sort(prior_band_chart()))
      )
    })




  lookup_characters <- qual_lookup %>%
    mutate(across(c(SUBLEVNO, SUBJ, SIZE, ASIZE, GSIZE, gradeStructure), ~ as.character(.x)))

  # use this output to update the prior band drop down box below
  prior_band_chart <- reactive({
    req(input$qual_select)
    stud_percentages %>%
      left_join(lookup_characters, by = c(
        "ReportYr",
        "Qual_Description", "SUBLEVNO", "Subject", "SUBJ",
        "ASIZE", "GSIZE", "SIZE", "gradeStructure"
      )) %>%
      subset(ReportYr == input$ReportYr_select &
        Qual_Description == input$qual_select &
        Subject == input$subj_select &
        SIZE == input$size_select &
        gradeStructure == input$grade_structure_select) %>%
      pull(PRIOR_BAND)
  })


  observe({
    updateSelectInput(session,
      inputId = "chart_band",
      label = NULL,
      choices = prior_band_chart()
    )
  })


  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Creating re-active lookups from drop down selections ----
  # -----------------------------------------------------------------------------------------------------------------------------
  ## Try and streamline the original code using reactive tables to prevent repetition
  lookup_selection <- reactive({
    qual_lookup %>%
      filter(ReportYr == input$ReportYr_select &
        Qual_Description == input$qual_select &
        Subject == input$subj_select &
        SIZE == input$size_select &
        gradeStructure == input$grade_structure_select) %>%
      distinct()
  })


  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Creating re-active tables from lookup above... depending on grading structures ----
  # -----------------------------------------------------------------------------------------------------------------------------

  # Create a reactive table for numbers table -----------------------------------------------
  # the function on the last line removes columns that are empty
  numbers_data <- reactive({
    req(c(lookup_selection()$ReportYr, lookup_selection()$SUBLEVNO, lookup_selection()$SUBJ, lookup_selection()$SIZE, lookup_selection()$gradeStructure))

    number_select_function(lookup_selection()$ReportYr, lookup_selection()$SUBLEVNO, lookup_selection()$SUBJ, lookup_selection()$SIZE, lookup_selection()$gradeStructure) %>%
      rename("Prior Band" = PRIOR_BAND)
  })



  # Create a reactive table for percentage table -----------------------------------------------
  percentage_data <- reactive({
    req(c(lookup_selection()$ReportYr, lookup_selection()$SUBLEVNO, lookup_selection()$SUBJ, lookup_selection()$SIZE, lookup_selection()$gradeStructure))

    percentage_select_function(lookup_selection()$ReportYr, lookup_selection()$SUBLEVNO, lookup_selection()$SUBJ, lookup_selection()$SIZE, lookup_selection()$gradeStructure) %>%
      mutate_all(list(~ str_replace(., "NA%", ""))) %>%
      rename("Prior Band" = PRIOR_BAND)
  })





  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Creating output tables ----
  # -----------------------------------------------------------------------------------------------------------------------------

  # Create example table -----------------------------------------------
  output$example_table <- DT::renderDataTable({
    datatable(
      example_data,
      options = list(
        columnDefs = list(list(className = "dt-center", targets = "_all")),
        bFilter = FALSE, bPaginate = FALSE, scrollX = TRUE
      )
    ) %>%
      formatStyle("C", "Prior Band",
        backgroundColor = styleEqual("5-<6", "#D4CEDE")
      )
  })


  # Create TM table -----------------------------------------------
  # Select if numbers or percentage table to display
  tm_table_data <- reactive(if (input$format == "Numbers data") {
    numbers_data()
  } else {
    percentage_data()
  })

  # Create the output
  output$tm_table <- DT::renderDataTable({
    datatable(tm_table_data(),
      options = list(
        columnDefs = list(list(className = "dt-center", targets = "_all")),
        bFilter = FALSE, bPaginate = FALSE, scrollX = TRUE
      ),
      rownames = FALSE
    )
  })





  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Creating the percentage plots... doesn't depend on grading structure so just use percentage_select_qrd_1 ----
  # -----------------------------------------------------------------------------------------------------------------------------

  # The below code removes columns that have an NA value. The purrr functions were taken from this website:
  # https://community.rstudio.com/t/drop-all-na-columns-from-a-dataframe/5844




  # percentage_chart_data <- eventReactive(input$chart_band, {
  #   percentage_select_function(lookup_selection()$SUBLEVNO, lookup_selection()$SUBJ, lookup_selection()$SIZE, lookup_selection()$gradeStructure) %>%
  #     filter(PRIOR_BAND == input$chart_band) %>%
  #
  #     # Now we have our selected row data it needs cleaning up because these values are characters
  #     # First we'll turn it into a list
  #     map(~.x) %>%
  #     # Next we need to remove the % signs from the percentages
  #     # Then we'll set all 'x' and 'NA' to NA which, along with all numbers, will be converted to numeric using line below
  #     lapply(., function(x)gsub("[%]", "", x)) %>%
  #     na_if(., "x") %>%
  #     na_if(., "NA") %>%
  #     lapply(., function(x) if(all(grepl("^[0-9.]+$", x))) as.numeric(x) else x) %>%
  #     # Next we need to remove all NA's
  #     discard(~all(is.na(.x))) %>%
  #     # Map the list back into a tibble
  #     map_df(~.x) %>%
  #     reshape2::melt()
  # })


  percentage_chart_data <- reactive({
    percentage_select_function(lookup_selection()$ReportYr, lookup_selection()$SUBLEVNO, lookup_selection()$SUBJ, lookup_selection()$SIZE, lookup_selection()$gradeStructure) %>%
      filter(PRIOR_BAND == input$chart_band) %>%
      # Now we have our selected row data it needs cleaning up because these values are characters
      # Next we need to remove the % signs from the percentages
      # Then we'll set all 'x' and 'NA' to NA which, along with all numbers, will be converted to numeric using line below
      map_df(., ~ gsub("[%]", "", .x)) %>%
      mutate(across(everything(), ~ na_if(., "x"))) %>%
      mutate(across(everything(), ~ na_if(., "NA"))) %>%
      map(~.x) %>%
      lapply(., function(x) if (all(grepl("^[0-9.]+$", x))) as.numeric(x) else x) %>%
      # Next we need to remove all NA's
      discard(~ all(is.na(.x))) %>%
      # Map the list back into a tibble
      map_df(~.x) %>%
      reshape2::melt()
  })


  output$percentage_chart <- renderPlot(
    {
      req(input$format == "Percentage data")
      ggplot(percentage_chart_data(), aes(x = variable, y = value)) +
        geom_bar(stat = "identity", fill = "#407291", colour = "black") +
        xlab("Grades") +
        scale_y_continuous(
          name = paste("Percentage within", input$chart_band, "band achieving grade", sep = " "),
          expand = c(0, 0)
        ) +
        theme(
          # set size and spacing of axis tick labels
          axis.text.x = element_text(size = 15, vjust = 0.5),
          axis.text.y = element_text(size = 15, vjust = 0.5),
          # set size, colour and spacing of axis labels
          axis.title.x = element_text(size = 20, vjust = -0.5),
          axis.title.y = element_text(size = 20, vjust = 2.0),
          # sorting out the background colour, grid lines, and axis lines
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "transparent"),
          plot.background = element_rect(fill = "transparent", color = NA),
          axis.line = element_line(colour = "black")
        )
    },
    bg = "transparent"
  )






  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Download Buttons ----
  # -----------------------------------------------------------------------------------------------------------------------------

  # Necessary to fix the download button
  output$tm_data_download_filtered <- downloadHandler(
    filename = "KS5_tm_data_filtered.csv",
    content = function(file) {
      write.csv(tm_table_data(), file, row.names = FALSE)
    }
  )

  output$tm_data_download_numbers <- downloadHandler(
    filename = "all_number_data.csv",
    content = function(file) {
      write.csv(stud_numbers, file, row.names = FALSE)
    }
  )

  output$tm_data_download_percentage <- downloadHandler(
    filename = "all_percentage_data.csv",
    content = function(file) {
      write.csv(stud_percentages, file, row.names = FALSE)
    }
  )



  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- TM page title ----
  # -----------------------------------------------------------------------------------------------------------------------------


  output$tm_title <- renderUI({
    if (input$format == "Numbers data") {
      tags$b(paste0("Number of students per KS4 attainment band for selected KS5 options."),
        style = "font-size: 24px;"
      )
    } else {
      tags$b(paste0("Percentage of students per KS4 attainment band for selected KS5 options."),
        style = "font-size: 24px;"
      )
    }
  })
























  # Stop app ---------------------------------------------------------------------------------

  session$onSessionEnded(function() {
    stopApp()
  })
}
