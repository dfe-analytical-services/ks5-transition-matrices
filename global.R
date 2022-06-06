
library(shiny)
library(shinydashboard)
library(shinytest)
library(dplyr)
library(ggplot2)
library(purrr)
library(DT)
library(tidyr)
library(stringr)

# -----------------------------------------------------------------------------------------------------------------------------
# ---- Read in the Data from 01_data-processing ---- 
# -----------------------------------------------------------------------------------------------------------------------------


stud_numbers <- readRDS("./outputs/all_student_numbers.rds")
stud_percentages <- readRDS("./outputs/all_student_percentages.rds")

lookup <- readRDS("./outputs/lookup.rds")

grades_qrd <- readRDS("./outputs/grades_qrd.rds") 
quals_with_multi_grades <- readRDS("./outputs/mult_grade_structure.rds")
