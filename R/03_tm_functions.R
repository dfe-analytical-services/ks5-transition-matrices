# -----------------------------------------------------------------------------------------------------------------------------
# ---- TM Creation Script ----
# Contains the functions for creating the TM tables
# -----------------------------------------------------------------------------------------------------------------------------





# -----------------------------------------------------------------------------------------------------------------------------
# ---- Prior Grade boundaries ----
# -----------------------------------------------------------------------------------------------------------------------------

grade_boundaries = c("<1", "1-<2", "2-<3", "3-<4", "4-<5", "5-<6", "6-<7", "7-<8", "8-<9", "9>=")



# -----------------------------------------------------------------------------------------------------------------------------
# ---- Edits to the student exams data to make it useable in the functions below ----
# -----------------------------------------------------------------------------------------------------------------------------

# arrange to ensure that the ROW_ID column is in correct order. 
stud_numbers <- stud_numbers %>% 
  arrange(QUAL_ID, PRIOR_BAND)

stud_percentages <- stud_percentages %>% 
  arrange(QUAL_ID, PRIOR_BAND)



# also need to make sure that all grades have a column in these tables - even if its just filled with NAs
# list of all possible grades in the student exams data (built from the QRD)
grade_list_qrd <- unique(grades_qrd$GRADE) 

#column_list_exams <- names(stud_numbers)


# function which adds missing columns to the table
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
# ---- Numbers Table from QRD filtering grades on SUBLEVNO ----
# -----------------------------------------------------------------------------------------------------------------------------

# Returns a table from the Student Numbers CSV
number_select_qrd_1 = function(qual, subj, size){
  filter_selection = paste0(qual, subj, size)
  qual_grades = filter(grades_qrd, SUBLEVNO == qual)
  
  # Grades already sorted so just need to extract list of grades
  grade_list = qual_grades$GRADE
  
  table = stud_numbers %>% 
    filter(QUAL_ID == filter_selection) %>%  
    select(PRIOR_BAND, grade_list) 
  
  return(table)
}

# -----------------------------------------------------------------------------------------------------------------------------
# ---- Percentages Table from QRD filtering grades on SUBLEVNO ----
# -----------------------------------------------------------------------------------------------------------------------------

# Returns a table from the Student Percentages CSV
percentage_select_qrd_1 = function(qual, subj, size){
  filter_selection = paste0(qual, subj, size)
  qual_grades = filter(grades_qrd, SUBLEVNO == qual)
  
  # Grades already sorted so just need to extract list of grades
  grade_list = qual_grades$GRADE
  
  table = stud_percentages %>% 
    filter(QUAL_ID == filter_selection) %>%  
    select(PRIOR_BAND, grade_list)
  
  return(table)
}


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Numbers Table from QRD filtering grades on SUBLEVNO & SUBJ & ASIZE ----
# -----------------------------------------------------------------------------------------------------------------------------

# Returns a table from the Student Numbers CSV
number_select_qrd_2 = function(qual, subj, size){
  filter_selection = paste0(qual, subj, size)
  qual_grades = filter(grades_qrd, SUBLEVNO == qual & SUBJ == subj & ASIZE_nodecimal == size)
  
  # Grades already sorted so just need to extract list of grades
  grade_list = qual_grades$GRADE
  
  table = stud_numbers %>% 
    filter(QUAL_ID == filter_selection) %>%  
    select(PRIOR_BAND, grade_list) 
  
  return(table)
}

# -----------------------------------------------------------------------------------------------------------------------------
# ---- Percentages Table from QRD filtering grades on SUBLEVNO & SUBJ & ASIZE ----
# -----------------------------------------------------------------------------------------------------------------------------

# Returns a table from the Student Percentages CSV
percentage_select_qrd_2 = function(qual, subj, size){
  filter_selection = paste0(qual, subj, size)
  qual_grades = filter(grades_qrd, SUBLEVNO == qual & SUBJ == subj & ASIZE_nodecimal == size)
  
  # Grades already sorted so just need to extract list of grades
  grade_list = qual_grades$GRADE
  
  table = stud_percentages %>% 
    filter(QUAL_ID == filter_selection) %>%  
    select(PRIOR_BAND, grade_list)
  
  return(table)
}





# -----------------------------------------------------------------------------------------------------------------------------
# ---- Example Table ----
# -----------------------------------------------------------------------------------------------------------------------------

# Create a fixed table for example table

user_selection_example <- lookup %>%
  filter(`Qualification name` == 'GCE A level' & `Subject name` == 'Mathematics' & SIZE == 1) %>%
  distinct()


example_data <- number_select_qrd_1(user_selection_example$SUBLEVNO, user_selection_example$SUBJ, user_selection_example$size_lookup) %>%
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









