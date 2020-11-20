
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
  select("qualification_name" = "Qualification name", sublevno = SUBLEVNO, "subject_name" = "Subject name", 
         subj = SUBJ, asize = ASIZE.y, prior_band = PRIOR_BAND, grade = GRADE, count = COUNT)

raw_stud_percentages_lookup <- stud_percentages %>%
  pivot_longer(-c(QUAL_ID, PRIOR_BAND, ROW_ID, SUBLEVNO, SUBJ, ASIZE), names_to = "GRADE", values_to = "COUNT") %>%
  mutate(COUNT = as.numeric(gsub("%", "", COUNT))) %>%
  drop_na("COUNT") %>%
  select(SUBLEVNO, SUBJ, ASIZE, PRIOR_BAND, GRADE, COUNT)%>%
  mutate(SUBLEVNO = as.numeric(SUBLEVNO),
         SUBJ = as.numeric(SUBJ)) %>%
  left_join(lookup, by = c("SUBLEVNO" = "SUBLEVNO", "SUBJ" = "SUBJ", "ASIZE" = "size_lookup")) %>%
  select("qualification_name" = "Qualification name", sublevno = SUBLEVNO, "subject_name" = "Subject name", 
         subj = SUBJ, asize = ASIZE.y, prior_band = PRIOR_BAND, grade = GRADE, count = COUNT)









###################################################################################
#### ADD IN TIDY DATA COLUMNS
###################################################################################


# TIME COLUMNS - time_identifier will be reporting year, and time_period needs to be specified (see top of script)
# GEOGRAPHY COLUMNS - these are fixed and the same across all rows for this data
tidy_data_numbers <- raw_stud_numbers_lookup %>%
    mutate(time_identifier = "Academic year",
         time_period = reporting_year_value,
         geographic_level = "National",
         country_code = "E92000001",
         country_name = "England") %>%
    select(time_identifier, time_period, geographic_level, country_name, country_code,
           sublevno, qualification_name, subj, subject_name, asize, prior_band, grade, count)


tidy_data_percentages <- raw_stud_percentages_lookup %>%
  mutate(time_identifier = "Academic year",
         time_period = reporting_year_value,
         geographic_level = "National",
         country_code = "E92000001",
         country_name = "England") %>%
  select(time_identifier, time_period, geographic_level, country_name, country_code,
         sublevno, qualification_name, subj, subject_name, asize, prior_band, grade, count)




###################################################################################
#### WRITING OUT THE TIDY DATA TO CSV
###################################################################################

write_csv(tidy_data_numbers, path = "tm_numbers_tidy.csv")
write_csv(tidy_data_percentages, path = "tm_percentages_tidy.csv")






