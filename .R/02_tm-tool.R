# -----------------------------------------------------------------------------------------------------------------------------
# ---- TM Creation Script ----
# Contains the functions for creating the TM tables
# -----------------------------------------------------------------------------------------------------------------------------

# Package Import ----
library(dplyr)
library(ggplot2)
library(purrr)
library(DT)
library(tidyr)
library(stringr)

# -----------------------------------------------------------------------------------------------------------------------------
# ---- Read in the Data from 01_data-processing ---- 
# -----------------------------------------------------------------------------------------------------------------------------


stud_numbers <- readRDS('./outputs/all_student_numbers.rds')
stud_percentages <- readRDS('./outputs/all_student_percentages.rds')
lookup <- readRDS('./outputs/lookup.rds')
# grades <- readRDS('./outputs/grades.rds')
grades_qrd <- readRDS('./outputs/grades_qrd.rds') 

quals_with_multi_grades <- readRDS('./outputs/mult_grade_structure.rds')





# -----------------------------------------------------------------------------------------------------------------------------
# ---- Edits to the student exams data to make it useable in the functions below ----
# -----------------------------------------------------------------------------------------------------------------------------

# How to ensure that the ROW_ID column is correctly arranged. 
stud_numbers <- stud_numbers %>% 
  arrange(QUAL_ID, PRIOR_BAND)

stud_percentages <- stud_percentages %>% 
  arrange(QUAL_ID, PRIOR_BAND)



# Also need to make sure that all grades have a column in these tables - even if its just filled with NAs
# Grades which do not have a column in the student exams data
grade_list_qrd <- unique(grades_qrd$GRADE) 

#column_list_exams <- names(stud_numbers)


# Function which adds missing columns to the table
add_missing_cols <- function(data, cname) {
  add <-cname[!cname %in% names(data)]
  
  if(length(add)!=0) data[add] <- NA
  data
}

stud_numbers <- add_missing_cols(stud_numbers, grade_list_qrd)
stud_percentages <- add_missing_cols(stud_percentages, grade_list_qrd)

# Note some difficulty below
# Want to get the grades column in the right order such that numeric values and characters ascend
#> sort(z, decreasing = FALSE) ASCENDING
#[1] "1" "5" "7" "a" "g" "z"
#> sort(z, decreasing = TRUE) DESCENDING
#[1] "z" "g" "a" "7" "5" "1"




# -----------------------------------------------------------------------------------------------------------------------------
# ---- Numbers Table from QRD filtering grades on SUBLEVNO & SUBJ ----
# -----------------------------------------------------------------------------------------------------------------------------

# Returns a table from the Student Numbers CSV
number_select_qrd = function(qual, subj, size){
  filter_selection = paste0(qual, subj, size)
  qual_grades = filter(grades_qrd, SUBLEVNO == qual & SUBJ == subj)
  
  # Grades already sorted so just need to extract list of grades
  grade_list = qual_grades$GRADE
  
  table = stud_numbers %>% 
    filter(QUAL_ID == filter_selection) %>%  
    select(PRIOR_BAND, grade_list) 
  
  return(table)
}

# -----------------------------------------------------------------------------------------------------------------------------
# ---- Percentages Table from QRD filtering grades on SUBLEVNO & SUBJ ----
# -----------------------------------------------------------------------------------------------------------------------------

# Returns a table from the Student Percentages CSV
percentage_select_qrd = function(qual, subj, size){
  filter_selection = paste0(qual, subj, size)
  qual_grades = filter(grades_qrd, SUBLEVNO == qual & SUBJ == subj)
  
  # Grades already sorted so just need to extract list of grades
  grade_list = qual_grades$GRADE
  
  table = stud_percentages %>% 
    filter(QUAL_ID == filter_selection) %>%  
    select(PRIOR_BAND, grade_list)
  
  return(table)
}



# -----------------------------------------------------------------------------------------------------------------------------
# ---- Numbers Table - for use with grades produced in 01_data-processing
# if using this remember to update server.R - one update for numbers, two for percentages ----
# -----------------------------------------------------------------------------------------------------------------------------

# Returns a table from the Student Numbers CSV
# number_select = function(qual, subj, size){
#   filter_selection = paste0(qual, subj, size)
#   qual_grades = filter(grades, SUBLEVNO == qual)
#   
#   # Would like to sort numeric and character grades differently so that all grades go from low - high
#   which_char_grades =  which(is.na(suppressWarnings(as.numeric(qual_grades$GRADE))))
#   character_grades = qual_grades$GRADE[which_char_grades]
#   number_grades = qual_grades$GRADE[-which_char_grades]
#   
#   sort_char_grades = sort(character_grades, decreasing = TRUE)
#   sort_num_grades = sort(number_grades)
#   
#   comb_grades = append(sort_char_grades, sort_num_grades)
#   #print(comb_grades)
#   
#   table = stud_numbers %>% 
#     filter(QUAL_ID == filter_selection) %>%  
#     select(PRIOR_BAND, comb_grades) 
#   
#   return(table)
# }

# -----------------------------------------------------------------------------------------------------------------------------
# ---- Percentages Table - for use with grades produced in 01_data-processing
# if using this remember to update server.R - one update for numbers, two for percentages ----
# -----------------------------------------------------------------------------------------------------------------------------

# Returns a table from the Student Percentages CSV
# percentage_select = function(qual, subj, size){
#   filter_selection = paste0(qual, subj, size)
#   qual_grades = filter(grades, SUBLEVNO == qual)
#   
#   # Would like to sort numeric and character grades differently so that all grades go from low - high
#   which_char_grades =  which(is.na(suppressWarnings(as.numeric(qual_grades$GRADE))))
#   character_grades = qual_grades$GRADE[which_char_grades]
#   number_grades = qual_grades$GRADE[-which_char_grades]
#   
#   sort_char_grades = sort(character_grades, decreasing = TRUE)
#   sort_num_grades = sort(number_grades)
#   
#   comb_grades = append(sort_char_grades, sort_num_grades)
#   #print(comb_grades)
#   
#   table = stud_percentages %>% 
#     filter(QUAL_ID == filter_selection) %>%  
#     select(PRIOR_BAND, comb_grades)
#   
#   return(table)
# }

# -----------------------------------------------------------------------------------------------------------------------------
# ---- Example Table ----
# -----------------------------------------------------------------------------------------------------------------------------

# Create a fixed table for example table

user_selection_example <- lookup %>% 
  filter(`Qualification name` == 'GCE A level' & `Subject name` == 'Mathematics' & ASIZE == 1) %>%
  distinct()


example_data <- number_select_qrd(user_selection_example$SUBLEVNO, user_selection_example$SUBJ, user_selection_example$size_lookup) %>%
    rename('Prior Band' = PRIOR_BAND) %>%
    .[!sapply(., function (x) all(is.na(x) | x == ""))]


# extract the value for example
example_value <- example_data %>%
  filter(`Prior Band` == '5-<6') %>%
  pull('C')




# -----------------------------------------------------------------------------------------------------------------------------
# ---- underlying data download - long table format ----
# -----------------------------------------------------------------------------------------------------------------------------

# re-format stud_numbers and stud_percentages in long table format for user download

raw_stud_numbers <- stud_numbers %>%
  pivot_longer(-c(QUAL_ID, PRIOR_BAND, ROW_ID, SUBLEVNO, SUBJ, ASIZE), names_to = "GRADE", values_to = "COUNT") %>%
  drop_na("COUNT") %>%
  select(SUBLEVNO, SUBJ, ASIZE, PRIOR_BAND, GRADE, COUNT)

raw_stud_percentages <- stud_percentages %>%
  pivot_longer(-c(QUAL_ID, PRIOR_BAND, ROW_ID, SUBLEVNO, SUBJ, ASIZE), names_to = "GRADE", values_to = "COUNT") %>%
  mutate(COUNT = as.numeric(gsub("%", "", COUNT))) %>%
  drop_na("COUNT") %>%
  select(SUBLEVNO, SUBJ, ASIZE, PRIOR_BAND, GRADE, COUNT)









