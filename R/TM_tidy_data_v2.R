
# Package Import ----
library(dplyr)
library(tidyr)
library(readr)


stud_numbers <- readRDS('all_student_numbers.rds')
stud_percentages <- readRDS('all_student_percentages.rds')

reporting_year_value = 201819

lookup <- readRDS('lookup.rds')
#grades <- readRDS('grades.rds')
grades_qrd <- readRDS('grades_qrd.rds') 
#quals_with_multi_grades <- readRDS('mult_grade_structure.rds')




raw_stud_numbers_lookup <- stud_numbers %>%
  pivot_longer(-c(QUAL_ID, PRIOR_BAND, ROW_ID, SUBLEVNO, SUBJ, ASIZE), names_to = "GRADE", values_to = "COUNT") %>%
  drop_na("COUNT") %>%
  select(SUBLEVNO, SUBJ, ASIZE, PRIOR_BAND, GRADE, COUNT) %>%
  mutate(SUBLEVNO = as.numeric(SUBLEVNO),
         SUBJ = as.numeric(SUBJ)) %>%
  left_join(lookup, by = c("SUBLEVNO" = "SUBLEVNO", "SUBJ" = "SUBJ", "ASIZE" = "size_lookup")) %>%
  select("Qualification name", SUBLEVNO, "Subject name", SUBJ, ASIZE = ASIZE.y, PRIOR_BAND, GRADE, COUNT)

raw_stud_percentages_lookup <- stud_percentages %>%
  pivot_longer(-c(QUAL_ID, PRIOR_BAND, ROW_ID, SUBLEVNO, SUBJ, ASIZE), names_to = "GRADE", values_to = "COUNT") %>%
  mutate(COUNT = as.numeric(gsub("%", "", COUNT))) %>%
  drop_na("COUNT") %>%
  select(SUBLEVNO, SUBJ, ASIZE, PRIOR_BAND, GRADE, COUNT)%>%
  mutate(SUBLEVNO = as.numeric(SUBLEVNO),
         SUBJ = as.numeric(SUBJ)) %>%
  left_join(lookup, by = c("SUBLEVNO" = "SUBLEVNO", "SUBJ" = "SUBJ", "ASIZE" = "size_lookup")) %>%
  select("Qualification name", SUBLEVNO, "Subject name", SUBJ, ASIZE = ASIZE.y, PRIOR_BAND, GRADE, COUNT)




###################################################################################
#### USING THE QRD TO SEPERATE QUALIFICATIONS WITH DIFFERENT GRADE STRUCTRES
###################################################################################


## creates a grid of grades for all qualifications
qualification_grade_structure <- grades_qrd %>%
  select(SUBLEVNO, GRADE) %>%
  distinct() %>%
  pivot_wider(names_from = "GRADE", values_from = "GRADE")

## group qualifications with same grades- creates a list of dataframes
qualification_grade_grouped <- qualification_grade_structure %>%
  group_by_at(vars(-SUBLEVNO)) %>%
  mutate(group_indices()) %>%
  group_split()

## steps through the list and removes unused grade columns
qualification_grade_grouped_tidy <- lapply(qualification_grade_grouped, function(df) {
  Filter(function(x)!all(is.na(x)), df)
})


## steps through the list adds extra column - concat of grades 
qualification_grade_concat <- lapply(qualification_grade_grouped_tidy, function(df) {
  df %>%
    unite(grade_concat, -c("SUBLEVNO", "group_indices()"), sep = "_", remove=FALSE)
  # mutate(grade_concat = paste(-SUBLEVNO, -group_indices(), sep = '_'))
})



###################################################################################
#### JOINING THE NUMBERS DATA
###################################################################################

## steps through the list and joins subject and size data 
qualification_grade_join_numbers <- lapply(qualification_grade_concat, function(df) {
  inner_join(df, raw_stud_numbers_lookup, by = "SUBLEVNO")
})


## steps through the list and includes tidy data columns
# TIME COLUMNS - time_identifier will be reporting year, and time_period needs to be specified (see top of script)
# GEOGRAPHY COLUMNS - these are fixed and the same across all rows for this data
tidy_data_numbers_listdf <- lapply(qualification_grade_join_numbers, function(df) {
  df %>%
    mutate(time_identifier = "Academic year",
           time_period = reporting_year_value,
           geographic_level = "National",
           country_code = "E92000001",
           country_name = "England") %>%
    select(time_identifier, time_period, geographic_level, country_name, country_code,
           SUBLEVNO, SUBJ, ASIZE, PRIOR_BAND, GRADE, COUNT, grade_concat)
})




###################################################################################
#### JOINING THE PERCENTAGE DATA
###################################################################################

## steps through the list and joins subject and size data 
qualification_grade_join_percentage <- lapply(qualification_grade_concat, function(df) {
  inner_join(df, raw_stud_percentages_lookup, by = "SUBLEVNO")
})


## steps through the list and includes tidy data columns
# TIME COLUMNS - time_identifier will be reporting year, and time_period needs to be specified (see top of script)
# GEOGRAPHY COLUMNS - these are fixed and the same across all rows for this data
tidy_data_percentages_listdf <- lapply(qualification_grade_join_percentage, function(df) {
  df %>%
    mutate(time_identifier = "Academic year",
           time_period = reporting_year_value,
           geographic_level = "National",
           country_code = "E92000001",
           country_name = "England") %>%
    select(time_identifier, time_period, geographic_level, country_name, country_code,
           SUBLEVNO, SUBJ, ASIZE, PRIOR_BAND, GRADE, COUNT, grade_concat)
})



###################################################################################
#### WRITING OUT THE TIDY DATA TO CSV
###################################################################################


tidy_data_numbers_singledf <- bind_rows(tidy_data_numbers_listdf)
tidy_data_percentages_singledf <- bind_rows(tidy_data_percentages_listdf)


write_csv(tidy_data_numbers_singledf, path = "tm_numbers_tidy_v2.csv")
write_csv(tidy_data_percentages_singledf, path = "tm_percentages_tidy_v2.csv")







