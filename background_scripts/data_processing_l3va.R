# -----------------------------------------------------------------------------------------------------------------------------
# ---- Gathering the data from the exams and lookup file ---- 
# This script is intended to be ran once, with the outputs automatically saved. Providing there is no updates to the underlying data, it is not necessary to run again
# this script for subsequent visits to the app.
# -----------------------------------------------------------------------------------------------------------------------------


# Package Import ----
library(odbc)
library(DBI)
library(dplyr)
library(stringr)
library(tidyr)
library(data.table)
library(formattable)
library(caTools)
library(dbplyr)


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Things to change between runs ----
# -----------------------------------------------------------------------------------------------------------------------------

# exam and lookup file sources to be updated each year

###### ----- 2021 unamended Data ----- #####
exam_file = "[L3VA].[U2022].[FILTERED_EXAMS_PROVIDERS]"
lookup_file = "[L3VA].[U2022].[QUAL_SUBJ_LOOKUP]"



# qualifications with character and numeric grading, e.g D1, D2...
# can use QA check in sections below to see if there are any new qualifications to add to this list
sublevno_char_num = c(113, 114)



# -----------------------------------------------------------------------------------------------------------------------------
# ---- Reading in the data from SQL tables ----
# -----------------------------------------------------------------------------------------------------------------------------


# establish connection to server
con <- DBI::dbConnect(odbc::odbc(), driver = "SQL Server",
                      server = "3dcpri-pdb16\\acsqls")

# select data from SQL tables
exams_data <- tbl(con, sql(paste("select * from", exam_file, "where GRADE <> 'Q'"))) %>% collect()

lookup <- tbl(con, sql(paste("select [Qualification name], SUBLEVNO, [Subject name], SUBJ, SIZE 
                          from", lookup_file, "where EXAM_COHORT not in (1)"))) %>% collect()

# disconnect
DBI::dbDisconnect(con)



# -----------------------------------------------------------------------------------------------------------------------------
# ---- Check for sublevno_char_num ---- 
# -----------------------------------------------------------------------------------------------------------------------------

letters_only <- function(x) !grepl("[^A-Za-z]", x)
numbers_only <- function(x) !grepl("\\D", x)

sublevno_char_num_qa <- exams_data %>%
  mutate(grade_list = ifelse(letters_only(GRADE) == TRUE |
                               numbers_only(GRADE) == TRUE,
                             FALSE, GRADE)) %>%
  select (SUBLEVNO, GRADE, grade_list) %>%
  group_by(SUBLEVNO, grade_list) %>%
  filter(grade_list != FALSE) %>%
  summarise()


# remove 113 and 114 because we already know about them, and 130 for the IB
sublevno_char_num_qa_filtered <- sublevno_char_num_qa %>%
  filter(!(SUBLEVNO %in% c(113, 114, 130)))

# check list for any other quals with numbers and letters in the grades, can ignore **
# View(sublevno_char_num_qa_filtered)


# any extra qualifications in this list that have a number and a character making up their grades then they need to be added to the sublevno_char_num list 
# this is found in the section above 'Things to change between runs'





# -----------------------------------------------------------------------------------------------------------------------------
# ---- Qualification and Subject Lookup ----
# -----------------------------------------------------------------------------------------------------------------------------

# create new column which removes decimal point from SIZE 
lookup <- lookup %>%
  mutate(size_lookup = gsub("[.]", "", SIZE)) %>%
  arrange(SUBLEVNO)


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Create the prior attainment bands ----
# -----------------------------------------------------------------------------------------------------------------------------


tm_prior_bands <- exams_data %>% 
  filter(EXAM_COHORT != 1) %>% 
  select(SUBLEVNO, SUBJ, GRADE, ASIZE, PRIOR, QUAL_ID) %>% 
  mutate(PRIOR_BAND = case_when(PRIOR <1 ~ "<1", 
                                PRIOR >=1 & PRIOR <2 ~ "1-<2", 
                                PRIOR >=2 & PRIOR <3 ~ "2-<3",
                                PRIOR >=3 & PRIOR <4 ~ "3-<4",
                                PRIOR >=4 & PRIOR <5 ~ "4-<5",
                                PRIOR >=5 & PRIOR <6 ~ "5-<6",
                                PRIOR >=6 & PRIOR <7 ~ "6-<7",
                                PRIOR >=7 & PRIOR <8 ~ "7-<8",
                                PRIOR >=8 & PRIOR <9 ~ "8-<9",
                                PRIOR >=9 ~ "9>="), 
         QUAL_ID = stringr::str_remove(QUAL_ID, ".")) 
# this removes the first character from the QUAL_ID variable as '.' represents a single character. 

# remove the exmas_data variable to free up space 
# rm(exams_data)




# -----------------------------------------------------------------------------------------------------------------------------
# ---- Cross Tab - Assign count of values to grades ----
# -----------------------------------------------------------------------------------------------------------------------------

tm_grade_count <- tm_prior_bands %>% 
  # collapse synonyms of grades into one.
  mutate(GRADE = case_when(GRADE == "*A" | GRADE == "A*" ~ "*A", 
                           GRADE == "*D" | GRADE == "D*" ~ "D*", 
                           GRADE == "**D" | GRADE == "D**" ~ "D**", 
                           GRADE == "*DD" | GRADE == "DD*" ~ "DD*", 
                           GRADE == "DDM" | GRADE == "MDD" ~ "DDM",
                           GRADE == "F" ~ "U",
                           grepl("F", GRADE) ~ "FAIL",
                           TRUE ~ as.character(GRADE))) %>%
  
  # SUBLEVNOs in sublevno_char_num have numeric/character (P1, D1, M1) grading structure so don't want to strip letters from these
  mutate(GRADE = ifelse(is.na(as.numeric(str_extract_all(GRADE, "\\d+"))) | SUBLEVNO %in% sublevno_char_num, 
                        GRADE, as.numeric(str_extract_all(GRADE, "\\d+")))) %>%
  count(GRADE, QUAL_ID, PRIOR_BAND) %>% 
  mutate(ROW_ID = paste0(QUAL_ID, PRIOR_BAND), SUBLEVNO = substr(QUAL_ID, 1, 3), SUBJ = substr(QUAL_ID, 4, 8), 
         ASIZE = substr(QUAL_ID, 9, length(QUAL_ID))) %>% 
  arrange(ROW_ID) 




# -----------------------------------------------------------------------------------------------------------------------------
# ---- NUMBERS & PERCENTAGES CALCULATED ---- 
# -----------------------------------------------------------------------------------------------------------------------------

# spread the grades across into their own columns
# calculate the percentage data

student_numbers_l3va <- tm_grade_count %>% pivot_wider(names_from = GRADE, values_from = n)

student_percentages_l3va <- student_numbers_l3va %>% 
  janitor::adorn_percentages() %>%
  mutate_if(is.numeric, function(x){round(x*100, 2)}) %>%
  mutate_if(is.numeric, ~paste0(.x, "%"))



# -----------------------------------------------------------------------------------------------------------------------------
# ---- Saving Data ---- 
# -----------------------------------------------------------------------------------------------------------------------------

# saveRDS(student_numbers_l3va, "./outputs/all_student_numbers_l3va.rds")
# saveRDS(student_percentages_l3va, "./outputs/all_student_percentages_l3va.rds")
# saveRDS(lookup, "./outputs/lookup_l3va.rds")


