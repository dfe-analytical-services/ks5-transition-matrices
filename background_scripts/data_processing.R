


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Load packages ----
# -----------------------------------------------------------------------------------------------------------------------------

library(odbc)
library(DBI)
library(dplyr)
library(dbplyr)
library(tidyr)
library(janitor)
library(readr)


rm(list=ls())

# -----------------------------------------------------------------------------------------------------------------------------
# ---- Source functions ----
# -----------------------------------------------------------------------------------------------------------------------------

source("./background_scripts/data_processing_func.R")

# -----------------------------------------------------------------------------------------------------------------------------
# ---- Things to change between runs ----
# -----------------------------------------------------------------------------------------------------------------------------

ancillary_save_path <- "//lonnetapp01/DSGA2/!!Secure Data/SFR/2023/KS5/November_2023/06_ancillary/"
current_year <- "2023U"

# -----------------------------------------------------------------------------------------------------------------------------
# ---- Thing to add - Reading in the data from SQL tables and running function ----
# -----------------------------------------------------------------------------------------------------------------------------

# establish connection to server
con <- DBI::dbConnect(odbc::odbc(), driver = "SQL Server", server = "VMT1PR-DHSQL02")


# Select data from SQL tables - need to add the current year for unamended run and change from U to A for the amended run

tm_data_raw_2023 <- tbl(con, sql("select * from [KS5_STATISTICS_RESTRICTED].[TM_2023].[TM_data_2023U]")) %>% collect()
tm_data_raw_2022 <- tbl(con, sql("select * from [KS5_STATISTICS_RESTRICTED].[TM_2022].[TM_data_2022A]")) %>% collect()

# disconnect
DBI::dbDisconnect(con)


# add current year to the function call to produce the processed data - only needs updating for unamended runs as 
# the SQL update above deals with version

processed_data_2023 <- TM_data_prod_func(tm_data_raw_2023, 2023)
processed_data_2022 <- TM_data_prod_func(tm_data_raw_2022, 2022)


# This needs updating to make sure it is the current year data as it is used to produce the ancillary data
# should only need updating for unamended run as with the above

current_year_data <- processed_data_2023


# -----------------------------------------------------------------------------------------------------------------------------
# ---- ANCILLARY DATA FOR EES ---- 
# -----------------------------------------------------------------------------------------------------------------------------

ancillary_data_numbers <- current_year_data$student_numbers %>%
  select(-ReportYr) %>% 
  pivot_longer(!c(Qual_Description, SUBLEVNO, Potential_Level, ASIZE, GSIZE, MAPPING, Subject, gradeStructure, PRIOR_BAND, SUBJ, SIZE, QUAL_ID, ROW_ID),
               names_to = "grade",
               values_to = "count") %>%
  select(qualification_name = Qual_Description,
         qualification_code = SUBLEVNO,
         subject_name = Subject,
         subject_code = SUBJ,
         size = SIZE,
         grade_structure = gradeStructure,
         prior_attainment_band = PRIOR_BAND,
         grade,
         count) %>%
  filter(!is.na(count)) %>%
  arrange(qualification_code, subject_code, size, grade_structure, prior_attainment_band, grade)


ancillary_data_percentages <- current_year_data$student_percentages %>%
  select(-ReportYr) %>% 
  pivot_longer(!c(Qual_Description, SUBLEVNO, Potential_Level, ASIZE, GSIZE, MAPPING, Subject, gradeStructure, PRIOR_BAND, SUBJ, SIZE, QUAL_ID, ROW_ID),
               names_to = "grade",
               values_to = "percentage") %>%
  select(qualification_name = Qual_Description,
         qualification_code = SUBLEVNO,
         subject_name = Subject,
         subject_code = SUBJ,
         size = SIZE,
         grade_structure = gradeStructure,
         prior_attainment_band = PRIOR_BAND,
         grade,
         percentage) %>%
  filter(percentage != "NA%") %>%
  arrange(qualification_code, subject_code, size, grade_structure, prior_attainment_band, grade)


ancillary_data <- ancillary_data_numbers %>%
  left_join(ancillary_data_percentages)



write_csv(ancillary_data, paste0(ancillary_save_path, 'tm_numbers_percentages_', current_year, '.csv'))


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Saving Data ---- 
# -----------------------------------------------------------------------------------------------------------------------------

# bind all the processed data

student_numbers <- lapply(ls(pattern = "processed_data_", .GlobalEnv), function(x){
  bind_rows(mget(x, .GlobalEnv)[[1]]["student_numbers"])}) %>% bind_rows()

student_percentages <- lapply(ls(pattern = "processed_data_", .GlobalEnv), function(x){
  bind_rows(mget(x, .GlobalEnv)[[1]]["student_percentages"])}) %>% bind_rows() 

qual_lookup <- lapply(ls(pattern = "processed_data_", .GlobalEnv), function(x){
  bind_rows(mget(x, .GlobalEnv)[[1]]["qual_lookup"])}) %>% bind_rows()

grades_ordered_lookup <- lapply(ls(pattern = "processed_data_", .GlobalEnv), function(x){
  bind_rows(mget(x, .GlobalEnv)[[1]]["grades_ordered_lookup"])}) %>% bind_rows()


# save as rds files

saveRDS(student_numbers, "./data/all_student_numbers.rds")
saveRDS(student_percentages, "./data/all_student_percentages.rds")

saveRDS(qual_lookup, "./data/qual_lookup.rds")
saveRDS(grades_ordered_lookup, "./data/grade_lookup.rds")

