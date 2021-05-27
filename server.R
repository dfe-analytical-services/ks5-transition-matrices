# -----------------------------------------------------------------------------------------------------------------------------
# ---- server.R ----
# Finds and consolidates the data ready to be shown in app, including updates to user inputs
# -----------------------------------------------------------------------------------------------------------------------------

library(shiny)

server = shinyServer(function(input, output, session) {
  
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- BUILDING A REACTIVE LOOKUP FROM THE USER SELECTION FROM DROPDOWNS ----
  # -----------------------------------------------------------------------------------------------------------------------------
  ## the user selection reactive table will also be a lookup table, 
  ## it shows how the names the user selected correspond to the SUBLEVNOs, SUBJ, and size_lookup
  
  user_selection <- reactive({
    lookup %>% filter(`Qualification name` == input$qual_select & `Subject name` == input$subj_select & ASIZE == input$size_select) %>%
      distinct()
  })
  
  
  
  
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Updates to drop down boxes - SUBJECT CHOICES ----
  # -----------------------------------------------------------------------------------------------------------------------------
  # The below code alters the options in the subject select drop down by only showing the subjects available for the chosen qualification
  # qualifications with only one subject, and subjects with multiple sizes require special formatting
  
  
  subject_choices = reactive({
    ## single subjects
    if(input$qual_select %in% c('Extended Project (Diploma)', 'Applied GCE AS level Double Award',
                                'OCR Cambridge Technical Extended Diploma at Level 3',
                                'International Baccalaureate',
                                'OCR Cambridge Technical Introductory Diploma at Level 3')){
      lookup %>% filter(`Qualification name` == input$qual_select) %>%
        select(`Subject name`) %>% 
        distinct() %>% 
        unlist(use.names = FALSE)
    }

    else{
      lookup %>% filter(`Qualification name` == input$qual_select) %>%
        select(`Subject name`) %>% 
        distinct() %>% 
        arrange(`Subject name`) %>% 
        unlist(use.names = FALSE)
    }
  })


  observe({
    updateSelectInput(session, "subj_select",
                      choices = subject_choices()
    )})
  
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Updates to drop down boxes - SIZE CHOICES ----
  # -----------------------------------------------------------------------------------------------------------------------------

  size_choices = reactive({
    if(input$qual_select == 'Other General Qualification at Level 3' & 
       input$subj_select %in% c('Medical Science', 'Social Science')){
      lookup %>% filter(`Qualification name` == input$qual_select) %>% 
        filter(`Subject name` == input$subj_select) %>% 
        select(ASIZE) %>% 
        distinct() %>%
        arrange(ASIZE) %>%
        unlist(use.names = FALSE)
    }
    
    else if (input$qual_select == 'VRQ Level 3' & 
             input$subj_select %in% c('Applied Sciences', 'Social Science', 'Applied Business',
                                      'Finance / Accounting (General)', 'Nutrition / Diet', 'Medical Science')){
      lookup %>% filter(`Qualification name` == input$qual_select) %>% 
        filter(`Subject name` == input$subj_select) %>% 
        select(ASIZE) %>% 
        distinct() %>%
        arrange(ASIZE) %>%
        unlist(use.names = FALSE)
    }
    
    ## single sizes
    else{
      lookup %>% filter(`Qualification name` == input$qual_select) %>% 
        filter(`Subject name` == input$subj_select) %>% 
        select(ASIZE) %>%
        unlist(use.names = FALSE)
    }
  })
  
  
  observe({
    updateSelectInput(session, "size_select",
                      choices = size_choices()
    )})
  
  
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Updates to drop down boxes - PRIOR BAND CHOICES ----
  # -----------------------------------------------------------------------------------------------------------------------------
  
  prior_band_chart <- reactive({
    stud_percentages %>% 
      subset(SUBLEVNO == user_selection()$SUBLEVNO & 
               SUBJ == user_selection()$SUBJ & 
               ASIZE == user_selection()$size_lookup) %>% 
      pull(PRIOR_BAND)
  })
  
  observe({
    updateSelectInput(session, inputId = 'chart_band',
                      choices = prior_band_chart())
  })
  

  
  
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- REACTIVE TABLES FOR THE TABLES DISPLAYED IN APPS ----
  # -----------------------------------------------------------------------------------------------------------------------------
  
  # Create a reactive table for numbers table
  # the function on the last line removes columns that are empty
  numbers_data <- reactive({
    number_select_qrd(user_selection()$SUBLEVNO, user_selection()$SUBJ, user_selection()$size_lookup) %>%
      rename('Prior Band' = PRIOR_BAND)
  })
  
  # Create a reactive table for percentage table
  percentage_data <- reactive({
    percentage_select_qrd(user_selection()$SUBLEVNO, user_selection()$SUBJ, user_selection()$size_lookup)  %>%
      mutate_all(list(~str_replace(., 'NA%', ''))) %>% 
      rename('Prior Band' = PRIOR_BAND)
  })
  
  
  
  
  
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- OUTPUTTING THE TABLES FOR THE APP ----
  # -----------------------------------------------------------------------------------------------------------------------------
  # Create the output number table
  output$number_table <- DT::renderDataTable({
    datatable(
      numbers_data(), options = list(columnDefs = list(list(className = 'dt-center', targets = '_all')), bFilter = FALSE, bPaginate = FALSE, scrollX = TRUE))
  })
  
  # Create the output percentages table
  output$percentage_table <- DT::renderDataTable({
    datatable(
      percentage_data(), options = list(columnDefs = list(list(className = 'dt-center', targets = '_all')), bFilter = FALSE, bPaginate = FALSE, scrollX = TRUE))
  })
  
  # Create example table
  output$example_table <- DT::renderDataTable({datatable(
    example_data, options = list(columnDefs = list(list(className = 'dt-center', targets = '_all')), bFilter = FALSE, bPaginate = FALSE, scrollX = TRUE)) %>%
      formatStyle('C', 'Prior Band', 
                  backgroundColor = styleEqual('5-<6', '#D4CEDE')
      )
  })
  
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- PERCENTAGE PLOT ----
  # -----------------------------------------------------------------------------------------------------------------------------
  
  # The below code removes columns that have an NA value. The purrr functions were taken from this website:
  # https://community.rstudio.com/t/drop-all-na-columns-from-a-dataframe/5844
  
  output$percentage_chart = renderPlot({
    per_data = percentage_select_qrd(user_selection()$SUBLEVNO, user_selection()$SUBJ, user_selection()$size_lookup) %>% 
      filter(PRIOR_BAND == input$chart_band) %>%
      
      # Now we have our selected row data it needs cleaning up because these values are characters
      # First we'll turn it into a list
      map(~.x) %>% 
      # Next we need to remove the % signs from the percentages
      # Then we'll set all 'x' and 'NA' to NA which, along with all numbers, will be converted to numeric using line below
      lapply(., function(x)gsub('[%]', '', x)) %>%
      na_if(., 'x') %>%
      na_if(., 'NA') %>%
      lapply(., function(x) if(all(grepl('^[0-9.]+$', x))) as.numeric(x) else x) %>%
      # Next we need to remove all NA's
      discard(~all(is.na(.x))) %>%  
      # Map the list back into a tibble
      map_df(~.x) 
    
    # The minus one in the below select means that it will select all columns EXCEPT the first
    
    
    # print(reshape2::melt(per_data))
    # per_data <- subset(per_data, select=-c(PRIOR_BAND))
    
    
    per_data <- reshape2::melt(per_data)
    ggplot(per_data, aes(x = variable, y = value)) +
      geom_bar(stat = 'identity', fill = '#407291', colour='black') + 
      xlab('Grades') +
      scale_y_continuous(name = paste('Percentage within', input$chart_band, 'band achieving grade', sep = " "), 
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
                           panel.background = element_rect(fill = 'transparent'), 
                           plot.background = element_rect(fill = 'transparent', color = NA),
                           axis.line = element_line(colour = 'black')
                         )
  },
  bg = 'transparent'
  )
  
  
  
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- Download Button ----
  # -----------------------------------------------------------------------------------------------------------------------------
  

  output$tm_data_download_tab_1 <- downloadHandler(
    filename = "number_data.csv",
    content = function(file) {
      write.csv(numbers_data(), file, row.names = FALSE)
    })  
  
    output$tm_data_download_tab_2 <- downloadHandler(
    filename = "percentage_data.csv",
    content = function(file) {
      write.csv(percentage_data(), file, row.names = FALSE)
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

