# -----------------------------------------------------------------------------------------------------------------------------
# ---- server.R ----
# Finds and consolidates the data ready to be shown in app, including updates to user inputs
# -----------------------------------------------------------------------------------------------------------------------------

library(shiny)

server = shinyServer(function(input, output, session) {
  
  # # -----------------------------------------------------------------------------------------------------------------------------
  # # ---- Call loading screen ----
  # # -----------------------------------------------------------------------------------------------------------------------------
  # 
  # hide(id = "loading-content", anim = TRUE, animType = "fade")
  # show("app-content")
  
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Updates to drop down boxes ----
  # -----------------------------------------------------------------------------------------------------------------------------
  # The below code alters the options in the subject select drop down by only showing the corresponding subjects available
  # to the qualification that a user selects in the qualification select drop down
  # qualifications with only one subject, and subjects with multiple sizes require special formatting
  
  # we need to identify which qualifications have only 1 subject option
  # use this output to update the list below
  single_subj <-  lookup %>% group_by(SUBLEVNO) %>% filter(n()==1) 
  single_subj
  
  observe({
    updateSelectInput(session, inputId = "subj_select",
                      label = NULL, 
                      if (input$qual_select %in% c("Extended Project (Diploma)", "Pre-U Short Course Subject",
                                             "International Baccalaureate", "OCR Cambridge Technical Introductory Diploma at Level 3",
                                             "Other General Qualification at Level 2"))
                      {choices = lookup %>% filter(`Qualification name` == input$qual_select) %>% 
                        select(`Subject name`) %>% as.character()
                      }
                      else{
                        choices = lookup %>% filter(`Qualification name` == input$qual_select) %>% 
                          select(`Subject name`) %>% arrange(`Subject name`)
                      })
  })
  
  

  
  
  # we need to identify which subjects have multiple sizes
  # use this output to update the list below
  ind_size <- duplicated(lookup[,2:4])
  multiple_sizes <- lookup[ind_size,]
  multiple_sizes
  
  observe({
    updateSelectInput(session, inputId = "size_select",
                      label = NULL, 
                      if (input$qual_select == "VRQ Level 2" & input$subj_select %in% 
                          c("Hairdressing Services", "Accounting", "Beauty Therapy")) {
                        choices = lookup %>% filter(`Qualification name` == input$qual_select) %>% 
                          filter(`Subject name` == input$subj_select) %>% select(SIZE) 
                      }
                      else if (input$qual_select == "VRQ Level 3" & input$subj_select %in% 
                               c("Agriculture (General)", "Animal Husbandry: Specific Animals", "Applied Business",
                                 "Applied Sciences", "Building / Construction Operations (General / Combined)",
                                 "Childcare Skills", "Computing and IT Advanced Technician", "Engineering Studies",
                                 "Environmental Management", "Finance / Accounting (General)", "Food Preparation (General)", 
                                 "Health Studies", "Horses / Ponies Keeping", "Medical Science", "Music performance: Group",
                                 "Nutrition / Diet", "Social Science", "Speech & Drama", "Theatrical Makeup"
                                 )) {
                        choices = lookup %>% filter(`Qualification name` == input$qual_select) %>% 
                          filter(`Subject name` == input$subj_select) %>% select(SIZE) 
                      }
                      else if (input$qual_select == "BTEC National Extended Certificate L3 - Band F - P-D*" & 
                               input$subj_select == "Multimedia"
                               ) {
                        choices = lookup %>% filter(`Qualification name` == input$qual_select) %>% 
                          filter(`Subject name` == input$subj_select) %>% select(SIZE) 
                      }
                      else{
                        choices = lookup %>% filter(`Qualification name` == input$qual_select) %>% 
                          filter(`Subject name` == input$subj_select) %>% select(SIZE) %>% as.character()
                      })
  })
  
  

  
  
  # only want the prior band drop down box to appear if the percentage data checkbox has been selected
  
  output$chart_band_appear <- 
    renderUI({
      req(input$format == "Percentage data")
      selectInput("chart_band",
                  label = tags$span(style="color: black;", "Select a KS4 prior attainment band to display in the plot"),
                  list(bands = sort(grade_boundaries)))
    })
  
      
   
  
  
  
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
      )
    }
  })
  
  
  

  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Updating the prior band drop down box so that only applicable options appear ----
  # -----------------------------------------------------------------------------------------------------------------------------
      
  
  lookup_characters <- lookup %>%
    mutate(across(c(SUBLEVNO, SUBJ, SIZE), ~as.character(.x)))
  
  prior_band_chart <- reactive({
    req(input$qual_select)
    stud_percentages %>%
      left_join(lookup_characters, by = c("SUBLEVNO", "SUBJ", "ASIZE" = "SIZE")) %>%
      subset(`Qualification name` == input$qual_select &
               `Subject name` == input$subj_select &
               ASIZE == input$size_select) %>%
      pull(PRIOR_BAND)
  })


  observe({
    updateSelectInput(session, inputId = "chart_band",
                      label = NULL,
                      choices = prior_band_chart())
  })


  
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Creating re-active lookups from drop down selections ----
  # -----------------------------------------------------------------------------------------------------------------------------
  ## Try and streamline the original code using reactive tables to prevent repetition
  lookup_selection <- reactive({
    lookup %>% filter(`Qualification name` == input$qual_select & `Subject name` == input$subj_select & SIZE == input$size_select) %>%
      distinct()
  })
  

  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Creating re-active tables from lookup selections... depending on grading structures ----
  # -----------------------------------------------------------------------------------------------------------------------------
  
  # Create a reactive table for numbers table
  # the function on the last line removes columns that are empty
  numbers_data <- reactive({
    req(c(lookup_selection()$SUBLEVNO, lookup_selection()$SUBJ, lookup_selection()$size_lookup))
    if(lookup_selection()$SUBLEVNO %in% quals_with_multi_grades){
    number_select_qrd_2(lookup_selection()$SUBLEVNO, lookup_selection()$SUBJ, lookup_selection()$size_lookup) %>%
      rename("Prior Band" = PRIOR_BAND)
    }
    else{
      number_select_qrd_1(lookup_selection()$SUBLEVNO, lookup_selection()$SUBJ, lookup_selection()$size_lookup) %>%
        rename("Prior Band" = PRIOR_BAND)
    }
  })

  # Create a reactive table for percentage table
  percentage_data <- reactive({
    req(c(lookup_selection()$SUBLEVNO, lookup_selection()$SUBJ, lookup_selection()$size_lookup))
    if(lookup_selection()$SUBLEVNO %in% quals_with_multi_grades){
    percentage_select_qrd_2(lookup_selection()$SUBLEVNO, lookup_selection()$SUBJ, lookup_selection()$size_lookup)  %>%
      mutate_all(list(~str_replace(., "NA%", ""))) %>%
      rename("Prior Band" = PRIOR_BAND)
    }
    else{
      percentage_select_qrd_1(lookup_selection()$SUBLEVNO, lookup_selection()$SUBJ, lookup_selection()$size_lookup)  %>%
        mutate_all(list(~str_replace(., "NA%", ""))) %>%
        rename("Prior Band" = PRIOR_BAND)
    }
  })


  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Creating output tables ----
  # -----------------------------------------------------------------------------------------------------------------------------

  # Create example table
  output$example_table <- DT::renderDataTable({datatable(
    example_data, options = list(columnDefs = list(list(className = "dt-center", targets = "_all")), bFilter = FALSE, bPaginate = FALSE, scrollX = TRUE)) %>%
      formatStyle("C", "Prior Band",
                  backgroundColor = styleEqual("5-<6", "#D4CEDE"))
  })
  
  
  
 tm_table_data <- reactive(if(input$format == "Numbers data"){
   numbers_data()
  }
  else{
    percentage_data()
  })

  
  output$tm_table <- DT::renderDataTable({
    datatable(tm_table_data(), 
              options = list(columnDefs = list(list(className = "dt-center", targets = "_all")), 
                             bFilter = FALSE, bPaginate = FALSE, scrollX = TRUE),
              rownames = FALSE)
  })
  
  

    
  
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Creating the percentage plots... doesn't depend on grading structure so just use percentage_select_qrd_1 ----
  # -----------------------------------------------------------------------------------------------------------------------------
  
  # The below code removes columns that have an NA value. The purrr functions were taken from this website:
  # https://community.rstudio.com/t/drop-all-na-columns-from-a-dataframe/5844

  

  
  percentage_chart_data <- reactive({
    percentage_select_qrd_1(lookup_selection()$SUBLEVNO, lookup_selection()$SUBJ, lookup_selection()$size_lookup) %>%
      filter(PRIOR_BAND == input$chart_band) %>%
      
      # Now we have our selected row data it needs cleaning up because these values are characters
      # First we'll turn it into a list
      map(~.x) %>%
      # Next we need to remove the % signs from the percentages
      # Then we'll set all 'x' and 'NA' to NA which, along with all numbers, will be converted to numeric using line below
      lapply(., function(x)gsub("[%]", "", x)) %>%
      na_if(., "x") %>%
      na_if(., "NA") %>%
      lapply(., function(x) if(all(grepl("^[0-9.]+$", x))) as.numeric(x) else x) %>%
      # Next we need to remove all NA's
      discard(~all(is.na(.x))) %>%
      # Map the list back into a tibble
      map_df(~.x) %>%
      reshape2::melt() 
  })




  output$percentage_chart = renderPlot({
    req(input$format == "Percentage data")
    ggplot(percentage_chart_data(), aes(x = variable, y = value)) +
      geom_bar(stat = "identity", fill = "#407291", colour="black") +
      xlab("Grades") +
      scale_y_continuous(name = paste("Percentage within", input$chart_band, "band achieving grade", sep = " "),
                         expand = c(0, 0)) + theme(
                           # set size and spacing of axis tick labels
                           axis.text.x=element_text(size=15, vjust=0.5),
                           axis.text.y=element_text(size=15, vjust=0.5),
                           # set size, colour and spacing of axis labels
                           axis.title.x = element_text(size=20, vjust=-0.5),
                           axis.title.y = element_text(size=20, vjust=2.0),
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
  # ---- Download Button ----
  # -----------------------------------------------------------------------------------------------------------------------------
  
  # Necessary to fix the download button 
  output$tm_data_download_filtered <- downloadHandler(
    filename = "KS5_tm_data_filtered.csv",
    content = function(file) {
      write.csv(tm_table_data(), file, row.names = FALSE)
    })  
  
  output$tm_data_download_numbers <- downloadHandler(
    filename = "all_number_data.csv",
    content = function(file) {
      write.csv(raw_stud_numbers, file, row.names = FALSE)
    })  
  
  output$tm_data_download_percentage <- downloadHandler(
    filename = "all_percentage_data.csv",
    content = function(file) {
      write.csv(raw_stud_percentages, file, row.names = FALSE)
    })  
  
})

