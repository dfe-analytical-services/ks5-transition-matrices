

TM_data_prod_func <- function(sql_data, ReportYear) {
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- SORTING NAs ----
  # -----------------------------------------------------------------------------------------------------------------------------
  
  colSums(is.na(sql_data)) %>% as.data.frame() 
  # NAs in prior band which need removing
  # NAs in subj because no subj code was assigned within the SQL production code
  # SUBJ is assigned by joining on the QUAL_SUBJ_LOOKUP, 
  # but some subjects are filtered out of the L3VA process if they are not entered in 5 or more institutions
  # for the TMs we don't mind this rule, so we've decided to leave them in but we will have to create new SUBJ codes
  # to ensure I'm not overwriting any existing SUBJ codes, I'm generating 3 digit random numbers (SUBJ is usually 5 digits)
  
  
  tm_data_subj_na <- sql_data %>% 
    filter(!(is.na(PRIOR_BAND)),
           is.na(SUBJ)) %>%
    group_by(Subject) %>%
    mutate(SUBJ = sample(100:900,1))
  
  tm_data <- sql_data %>%
    filter(!(is.na(PRIOR_BAND)),
           !(is.na(SUBJ))) %>%
    bind_rows(tm_data_subj_na)
  
  colSums(is.na(tm_data)) %>% as.data.frame() 
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- NUMBERS & PERCENTAGES CALCULATED ---- 
  # -----------------------------------------------------------------------------------------------------------------------------
  
  student_numbers <- tm_data %>% 
    mutate(GRADE = case_when(GRADE == "Fail" & SUBLEVNO != 130 ~ "U",
                             TRUE ~ GRADE),
           SIZE = case_when(ASIZE == 0 ~ GSIZE, 
                            TRUE ~ ASIZE),
           QUAL_ID = paste0(SUBLEVNO, SUBJ, SIZE, gradeStructure),
           ROW_ID = paste0(SUBLEVNO, SUBJ, SIZE, PRIOR_BAND, gradeStructure)) %>%
    mutate(across(c(everything(), -total_students), ~as.character(.))) %>%
    arrange(ROW_ID) %>% 
    pivot_wider(names_from = GRADE, values_from = total_students)
  
  
  student_percentages <- student_numbers %>% 
    janitor::adorn_percentages() %>%
    mutate_if(is.numeric, function(x){round(x*100, 2)}) %>%
    mutate_if(is.numeric, ~paste0(.x, "%"))
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- LOOKUP & FULL GRADE OPTIONS CALCULATED ---- 
  # -----------------------------------------------------------------------------------------------------------------------------
  
  
  qual_lookup <- tm_data %>%
    select(Qual_Description, SUBLEVNO, Subject, SUBJ, ASIZE, GSIZE, gradeStructure) %>%
    distinct() %>%
    mutate(SIZE = case_when(ASIZE == 0 ~ GSIZE, 
                            TRUE ~ ASIZE))
  
  
  grade_lookup_u <- tm_data %>%
    select(SUBLEVNO, SUBJ, ASIZE, GSIZE, gradeStructure) %>%
    distinct() %>%
    mutate(GRADE = case_when(SUBLEVNO == 130 ~ "Fail",
                             TRUE ~ "U")) 
  
  grade_lookup_sep <- tm_data %>%
    select(SUBLEVNO, SUBJ, ASIZE, GSIZE, gradeStructure) %>%
    distinct() %>%
    mutate(GRADE = gradeStructure) %>%
    separate_rows(. , GRADE, sep = ",") 
  
  grade_lookup <- bind_rows(grade_lookup_u, grade_lookup_sep) %>%
    arrange(SUBLEVNO, SUBJ, ASIZE, GSIZE, gradeStructure, GRADE) %>%
    mutate(SIZE = case_when(ASIZE == 0 ~ GSIZE, 
                            TRUE ~ ASIZE))
  
  
  # would like to sort numeric and character grades differently so that all grades go from low - high
  # for numeric this is ascending, for character this is descending
  # will need to split again based on numeric and character and then re-combine again
  grades_char <- grade_lookup %>%
    mutate(char_grade_check = is.na(suppressWarnings(as.numeric(grade_lookup$GRADE)))) %>%  # gives extra column - True is character, False is number
    filter(char_grade_check == TRUE) %>% 
    arrange(desc(GRADE))
  
  grades_num <- grade_lookup %>%
    mutate(char_grade_check = is.na(suppressWarnings(as.numeric(grade_lookup$GRADE)))) %>%  # gives extra column - True is character, False is number
    filter(char_grade_check == FALSE) %>%
    arrange(GRADE)
  
  grades_ordered_lookup <- bind_rows(grades_char, grades_num) %>%
    arrange(SUBLEVNO)
  
  # -----------------------------------------------------------------------------------------------------------------------------
  # ---- add academic year to data ---- 
  # -----------------------------------------------------------------------------------------------------------------------------
  
  student_numbers <- student_numbers %>% 
    mutate(ReportYr = ReportYear) %>% 
    select(ReportYr, everything())
  
  student_percentages <- student_percentages %>% 
    mutate(ReportYr = ReportYear) %>% 
    select(ReportYr, everything())
  
  qual_lookup <- qual_lookup %>% 
    mutate(ReportYr = ReportYear) %>% 
    select(ReportYr, everything())
  
  grades_ordered_lookup <- grades_ordered_lookup %>% 
    mutate(ReportYr = ReportYear) %>% 
    select(ReportYr, everything())
  
  
  # grade_list %>% filter(SUBLEVNO == 253, SUBJ == 20596, ASIZE == 1)
  
  return(list(student_numbers = student_numbers, student_percentages = student_percentages, 
              qual_lookup = qual_lookup, grades_ordered_lookup = grades_ordered_lookup))
  
}
