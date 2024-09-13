# -----------------------------------------------------------------------------------------------------------------------------
# ---- Grading structure from the QRD ----
# This script is intended to be ran once, with the outputs automatically saved. Providing there is no updates to the underlying data, it is not necessary to run again
# -----------------------------------------------------------------------------------------------------------------------------

# qrd_grades_r returns the grading structure in the R format
# GRADES_EXCEL returns the grading structure in the EXCEL format
# QUALIFICATION_LOOKUP_EXCEL returns the subject lookup table in the EXCEL format
# SUBJECT_LOOKUP_EXCEL returns the subject lookup table in the EXCEL format
# QUALSUB_EXCEL returns the QualSub table in the EXCEL format
# SIZESUB_EXCEL returns the SizeSub table in the EXCEL format
# SIZE_LOOKUP_EXCEL returns the Size lookup table in the EXCEL format

# all_grades_combined is a big lookup table showing everything
# subscript_subj_lookup is a subset of all_grades_combined specifically showing which SUBLEVNO_subscript_2 is associated with which subject (no grade data)

# -----------------------------------------------------------------------------------------------------------------------------

rm(list = ls())

library(dplyr)
library(tidyr)
library(data.table)
library(stringr)


qrd_table0_file <- "[QRD].[dbo].[Subje01_2021_09_08]"
qrd_table2_file <- "[QRD].[dbo].[Table2_2021_09_08]"
qrd_table3_file <- "[QRD].[dbo].[Table3_2021_09_08]"
qrd_table4_file <- "[QRD].[dbo].[Table4_2021_09_08]"

exam_file <- "[L3VA].[U2021].[FILTERED_EXAMS_PROVIDERS]"
lookup_file <- "[L3VA].[U2021].[QUAL_SUBJ_LOOKUP]"

current_year <- 2021
# sublevno_char_num = c(113, 114)
# sublevno_char_num = list()


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Reading in the Data ----
# -----------------------------------------------------------------------------------------------------------------------------

# Establish connection to server
con <- DBI::dbConnect(odbc::odbc(),
  driver = "SQL Server",
  server = "3dcpri-pdb16\\acsqls"
)

# Select data from SQL tables
exams_data <- tbl(con, sql(paste("select * from", exam_file))) %>% collect()

lookup_data <- tbl(con, sql(paste("select [Qualification name], SUBLEVNO, [Subject name], SUBJ, SIZE
                          from", lookup_file, "where EXAM_COHORT not in (1)"))) %>% collect()

qrd_table0 <- tbl(con, sql(paste("select QUID, Qual_Type, Syllabus_Short_Title, Last_Used
                            from", qrd_table0_file))) %>% collect()

qrd_table2 <- tbl(con, sql(paste("select Qual_Type, Grade, Grade_Text, Year_Added, Last_Input_Year
                            from", qrd_table2_file))) %>% collect()

qrd_table3 <- tbl(con, sql(paste("select QUID, Grade, Grade_Text, Year_Added, Last_Input_Year
                            from", qrd_table3_file))) %>% collect()


qrd_table4 <- tbl(con, sql(paste("select Qual_Type, Qual_Number, Qual_Description, Potential_Level
                            from", qrd_table4_file))) %>% collect()

# Disconnect
DBI::dbDisconnect(con)


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Find a list of all SUBLEVNOs, GNUMBERS and SUBJECTS in the EXAMS data and LOOKUP data ----
# -----------------------------------------------------------------------------------------------------------------------------


# 1. create the SUBLEVNO list from the exams data - should include all qualifications in exams data, and the list of GNUMBERS that are in the data
SUBLEVNO_in_exams <- exams_data %>%
  select(SUBLEVNO) %>%
  distinct() %>%
  arrange(SUBLEVNO)


# 2. create a GNUMBER list from the exams data
# takes the first instance of each GNUMBER in the exams file
# PROBLEM: same GNUMBER for different subjects... Art & Design! 13510 13570 13650... etc all same GNUMBER 60149589
# need to group by SUBJ as well

GNUM_in_exams <- exams_data %>%
  group_by(GNUMBER, SUBJ) %>%
  slice(1) %>%
  ungroup() %>%
  select(SUBJ, GNUMBER, ASIZE, GSIZE) %>%
  rename(QUID = GNUMBER)


# 3. create a subject list from the QRD data, filtered to only include subjects from qualifications in the SUBLEVNO_in exams created above
# finds the subject names for the qualifications in the exam file
SUBJ_in_lookup <- lookup_data %>%
  filter(SUBLEVNO %in% SUBLEVNO_in_exams$SUBLEVNO) %>%
  select("Subject name", SUBJ)

# -----------------------------------------------------------------------------------------------------------------------------
# ---- Duplicate GNUMBERS for different Subjects ----
# -----------------------------------------------------------------------------------------------------------------------------


# 4,. create a list of the subjects that have multiple GNUMBERS
multiple_GNUM <- GNUM_in_exams %>%
  filter(QUID %in% unique(.[duplicated(.$QUID), ]$QUID)) %>%
  left_join(., SUBJ_in_lookup, by = "SUBJ") %>%
  distinct()



# -----------------------------------------------------------------------------------------------------------------------------
# ---- Find a list of all SUBLEVNOs in the EXAMS data and GNUMBERS for qualifications with different grading structures ----
# -----------------------------------------------------------------------------------------------------------------------------


# 5. From the QRD, create a list of SUBLEVNOs that have different grading structures for the subjects within it
qrd_tab_2_4 <- qrd_table2 %>%
  left_join(qrd_table4, by = "Qual_Type")

SUBLEVNO_diff_grades <- setdiff(SUBLEVNO_in_exams$SUBLEVNO, qrd_tab_2_4$Qual_Number)


# 6. use the list created from the QRD above to filter the exams data
# create a list of GNUMBERS (also known as QUID in the QRD) for the subjects that have different grade structures in comparison to others within their qualification
GNUMBER_diff_grades <- exams_data %>%
  filter(SUBLEVNO %in% SUBLEVNO_diff_grades) %>%
  select(GNUMBER, SUBJ) %>%
  distinct() %>%
  arrange(GNUMBER)


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Create two tabels from the QRD data which filter out the grades from the SUBLEVNOs found in the exams data ----
# -----------------------------------------------------------------------------------------------------------------------------

# 7. joins the two QRD tables with qualifications with same grades, orders by Qual_Number, filters out grades N Q R X and F
# make SUBLEVNO_subscript_2 column for when joining with table below later
same_grade_quals <- qrd_table2 %>%
  distinct() %>%
  left_join(qrd_table0, by = "Qual_Type") %>%
  left_join(qrd_table4, by = "Qual_Type") %>%
  arrange(Qual_Number) %>%
  filter(
    !Grade %in% c("N", "Q", "R", "X"),
    Grade != "F",
    Qual_Number %in% SUBLEVNO_in_exams$SUBLEVNO
  ) %>%
  mutate(SUBLEVNO_subscript = as.character(Qual_Number))


# 8. joins the two QRD tables with qualifications with different grades.
# make additional column to append subscripts in order to differentiate different QUIDS within the same qualification
# requires additional filter QUID %in% GNUMBER_diff_grades$GNUMBER because some of the qualifications have subjects that are not included in the TMs
diff_grade_quals <- qrd_table3 %>%
  left_join(qrd_table0, by = "QUID") %>%
  left_join(qrd_table4, by = "Qual_Type") %>%
  arrange(Qual_Number) %>%
  filter(
    !Grade %in% c("N", "Q", "R", "X"),
    Grade != "F",
    Qual_Number %in% SUBLEVNO_in_exams$SUBLEVNO,
    QUID %in% GNUMBER_diff_grades$GNUMBER
  )




# -----------------------------------------------------------------------------------------------------------------------------
# ---- Create a huge lookup tables FOR ALL QUALS ----
# -----------------------------------------------------------------------------------------------------------------------------

# 9. create large table for qualifications/subjects with same grading structure
# joining on tables to get SUBJ code, qualification sizes and subject names
all_same_grade_quals_subj <- same_grade_quals %>%
  left_join(., GNUM_in_exams, by = "QUID") %>%
  left_join(., SUBJ_in_lookup, by = "SUBJ") %>%
  arrange(Qual_Number) %>%
  distinct()

# 10. create large table for qualifications/subjects with different grading structures
# joining on tables to get SUBJ code, qualification sizes and subject names
# make additional column to append subscripts in order to differentiate different SUBJECTS within the same qualification
all_diff_grade_quals_subj <- diff_grade_quals %>%
  left_join(., GNUM_in_exams, by = "QUID") %>%
  left_join(., SUBJ_in_lookup, by = "SUBJ") %>%
  group_by(SUBJ) %>%
  mutate(subscript = cur_group_id()) %>%
  ungroup() %>%
  unite("SUBLEVNO_subscript", c(Qual_Number, subscript), na.rm = TRUE, remove = FALSE) %>%
  arrange(subscript) %>%
  distinct() %>%
  select(-subscript)


# 11. makes big lookup table for ALL qualifications and subjects
all_grades_combined <- bind_rows(all_same_grade_quals_subj, all_diff_grade_quals_subj)


# 12. qualification 699 does not appear in QRD as its just an extension of GCE AS level (Not continued to A2) (121)
grades_699 <- all_grades_combined %>%
  filter(Qual_Number == 111 | Qual_Number == 121) %>%
  mutate(
    Qual_Number = 699,
    SUBLEVNO_subscript = 699,
    Last_Used = 0,
    Qual_Description = "GCE AS level (All)",
    Syllabus_Short_Title = "",
    QUID = "",
    ASIZE = 0.5
  ) %>%
  distinct()


# 13. for level 2 qualifications, set ASIZE equal to GSIZE
all_grades_combined_final <- rbind(all_grades_combined, grades_699) %>%
  mutate(ASIZE = case_when(
    Potential_Level == 2 ~ GSIZE,
    TRUE ~ ASIZE
  ))


# -------------
# QA to check all subjects in 111 and 121 are present in 699 data
# -------------
subj_699 <- grades_699 %>%
  select("Subject name", SUBJ) %>%
  distinct()
subj_111 <- lookup_data %>%
  filter(SUBLEVNO == 111) %>%
  select("Subject name", SUBJ)
subj_121 <- lookup_data %>%
  filter(SUBLEVNO == 121) %>%
  select("Subject name", SUBJ)

# setdiff(subj_699, subj_121)
# setdiff(subj_699, subj_111)
subj_111_121 <- merge(subj_111, subj_121, all = TRUE)
setdiff(subj_699, subj_111_121)
# -------------


# 14. create smaller table showing which SUBLEVNO_subscript is associated with which subject (no grade data)
subscript_subj_lookup <- all_grades_combined_final %>%
  select(QUID, Qual_Number, Qual_Description, SUBLEVNO_subscript, SUBJ, `Subject name`) %>%
  distinct() %>%
  filter(!is.na(SUBJ))



# -----------------------------------------------------------------------------------------------------------------------------
# ---- Tidy grading structure, remove duplicates, fix IB (130), order grades low to high ----
# -----------------------------------------------------------------------------------------------------------------------------

# 15. select required columns and tidy similar grade names
# some of the international baccalaureate grades have a mix of character and numerical values but should only be numerical. others should only be characters (U)
# need to strip character values from some of the SUBLEVNO 130 without affecting the character grades or grades from other sublevnos
grade_tidy <- all_grades_combined_final %>%
  select(Qual_Number, SUBLEVNO_subscript, SUBJ, ASIZE, Grade, Year_Added, Last_Input_Year) %>%
  mutate(Grade = case_when(
    Grade == "*A" | Grade == "A*" ~ "*A",
    Grade == "*D" | Grade == "D*" ~ "D*",
    Grade == "**D" | Grade == "D**" ~ "D**",
    Grade == "*DD" | Grade == "DD*" ~ "DD*",
    Grade == "DDM" | Grade == "MDD" ~ "DDM",
    Grade == "PPM" | Grade == "MPP" ~ "MPP",
    Grade == "PMM" | Grade == "MMP" ~ "MMP",
    Grade == "MMD" | Grade == "DMM" ~ "DMM",
    Grade == "F" ~ "U",
    grepl("F", Grade) ~ "FAIL",
    TRUE ~ as.character(Grade)
  )) %>%
  mutate(Grade = ifelse(is.na(as.numeric(str_extract_all(Grade, "\\d+"))) | SUBLEVNO_subscript != 130,
    Grade, as.numeric(str_extract_all(Grade, "\\d+"))
  )) %>%
  distinct()


# 16. remove grades that have been updated by using the year added column
# grade_year_select <- grade_tidy %>%
#   select(-Grade) %>%
#   group_by(SUBLEVNO_subscript, SUBJ, ASIZE) %>%
#   arrange(desc(Year_Added)) %>%
#   slice_head() %>%
#   ungroup()
#
#
# grade_select <- grade_year_select %>%
#   left_join(grade_tidy)



# 16. remove grades that are no longer in use by using last input year column
grade_select <- grade_tidy %>%
  filter(Last_Input_Year == current_year)






# 17. arrange the grades
# would like to sort numeric and character grades differently so that all grades go from low - high
# for numeric this is ascending, for character this is descending
# will need to split again based on numeric and character and then re-combine again
grades_char <- grade_select %>%
  mutate(Char = is.na(suppressWarnings(as.numeric(grade_select$Grade)))) %>% # gives extra column - True is character, False is number
  filter(Char == TRUE) %>%
  arrange(desc(Grade))

grades_num <- grade_select %>%
  mutate(Char = is.na(suppressWarnings(as.numeric(grade_select$Grade)))) %>% # gives extra column - True is character, False is number
  filter(Char == FALSE) %>%
  arrange(Grade)

grades_ordered <- bind_rows(grades_char, grades_num) %>%
  arrange(SUBLEVNO_subscript) %>%
  subset(., !(SUBLEVNO_subscript == 130 & Grade == "U")) # removes IB grade U, because IB should only have FAIL





# -----------------------------------------------------------------------------------------------------------------------------
# ---- Re-arrange the data to match the format needed for R ----
# -----------------------------------------------------------------------------------------------------------------------------

qrd_grades_r <- grades_ordered %>%
  select(Qual_Number, SUBJ, ASIZE, Grade) %>%
  rename(
    SUBLEVNO = Qual_Number,
    GRADE = Grade
  ) %>%
  filter(!is.na(SUBJ)) %>%
  mutate(ASIZE_nodecimal = gsub("[.]", "", ASIZE))


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Saving Data ----
# -----------------------------------------------------------------------------------------------------------------------------

saveRDS(qrd_grades_r, "./outputs/grades_qrd.rds")
saveRDS(SUBLEVNO_diff_grades, "./outputs/mult_grade_structure.rds")







# -----------------------------------------------------------------------------------------------------------------------------
# ---- EXCEL ----
# -----------------------------------------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------------------------------------
# ---- Re-arrange the data to match the format from EXCEL ----
# -----------------------------------------------------------------------------------------------------------------------------


# Adds a third column counting each unique grade for a particular sublevno
grades_ordered_grouped <- grades_ordered %>%
  select(SUBLEVNO_subscript, Grade) %>%
  distinct() %>%
  group_by(SUBLEVNO_subscript) %>%
  mutate(grade_count = row_number()) %>%
  ungroup()


# Transposes the table into same structure as excel table
GRADES_EXCEL <- grades_ordered_grouped %>%
  reshape2::dcast(., SUBLEVNO_subscript ~ grade_count, value.var = "Grade", fill = "") %>%
  distinct()





# -----------------------------------------------------------------------------------------------------------------------------
# ---- Create QUALIFICATION LOOKUP ----
# -----------------------------------------------------------------------------------------------------------------------------
# need to make qualification lookups sep because quals with diff grades need subject names appending
# 699 also needs adding on manually


qual_names_EXCEL_ALL <- all_grades_combined_final %>%
  mutate(Qual_Name = case_when(
    !(Qual_Number %in% SUBLEVNO_diff_grades) | Qual_Number == 699 ~ Qual_Description,
    TRUE ~ paste(Qual_Description, `Subject name`, sep = " ")
  ))


QUALIFICATION_LOOKUP_EXCEL <- qual_names_EXCEL_ALL %>%
  select(SUBLEVNO_subscript, Qual_Name) %>%
  distinct()


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Create SUBJECT LOOKUP ----
# -----------------------------------------------------------------------------------------------------------------------------


SUBJECT_LOOKUP_EXCEL <- all_grades_combined_final %>%
  select(SUBJ, "Subject name") %>%
  distinct() %>%
  drop_na() %>%
  arrange(SUBJ)


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Create QUALSUB ----
# -----------------------------------------------------------------------------------------------------------------------------


qual_names_EXCEL_grouped <- qual_names_EXCEL_ALL %>%
  select(Qual_Name, SUBLEVNO_subscript, SUBJ) %>%
  distinct() %>%
  drop_na() %>%
  arrange(SUBLEVNO_subscript, SUBJ) %>%
  group_by(SUBLEVNO_subscript) %>%
  mutate(subj_count = row_number()) %>%
  ungroup()


QUALSUB_EXCEL <- qual_names_EXCEL_grouped %>%
  reshape2::dcast(., Qual_Name + SUBLEVNO_subscript ~ subj_count, value.var = "SUBJ", fill = "") %>%
  distinct() %>%
  arrange(SUBLEVNO_subscript)


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Create SIZESUB ----
# -----------------------------------------------------------------------------------------------------------------------------

size_EXCEL_grouped <- qual_names_EXCEL_ALL %>%
  select(Qual_Name, SUBLEVNO_subscript, ASIZE) %>%
  distinct() %>%
  drop_na() %>%
  arrange(ASIZE) %>%
  group_by(SUBLEVNO_subscript) %>%
  mutate(size_count = row_number()) %>%
  ungroup()


SIZESUB_EXCEL <- size_EXCEL_grouped %>%
  reshape2::dcast(., Qual_Name + SUBLEVNO_subscript ~ size_count, value.var = "ASIZE", fill = "") %>%
  distinct() %>%
  arrange(SUBLEVNO_subscript)


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Create SIZE LOOKUP ----
# -----------------------------------------------------------------------------------------------------------------------------

SIZE_LOOKUP_EXCEL <- qual_names_EXCEL_ALL %>%
  select(SUBLEVNO_subscript, Qual_Name, SUBJ, `Subject name`, ASIZE) %>%
  mutate(ASIZE = as.character(ASIZE)) %>%
  distinct() %>%
  drop_na()



# -----------------------------------------------------------------------------------------------------------------------------
# ---- QA Checks ----
# -----------------------------------------------------------------------------------------------------------------------------

# identify rows with QUID information but no subject information
# looking through the data these might be because the QUIDs are associated with qual/subj that were 'last taken' a few years ago?
no_subj_info <- all_grades_combined_final %>%
  select(QUID, Qual_Number, Qual_Description, SUBLEVNO_subscript, SUBJ, `Subject name`) %>%
  distinct() %>%
  filter(is.na(SUBJ))

# -----------------------------------------------------------------------------------------------------------------------------
