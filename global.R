# ---------------------------------------------------------
# This is the global file.
# Use it to store functions, library calls, source files etc.
# Moving these out of the server file and into here improves performance
# The global file is run only once when the app launches and stays consistent across users
# whereas the server and UI files are constantly interacting and responsive to user input.
#
# ---------------------------------------------------------


# Library calls ---------------------------------------------------------------------------------
shhh <- suppressPackageStartupMessages # It's a library, so shhh!
shhh(library(shiny))
shhh(library(shinyjs))
shhh(library(tools))
shhh(library(shinytest))
shhh(library(shinyWidgets))
shhh(library(shinyGovstyle))
shhh(library(dfeshiny))
shhh(library(shinycssloaders))
shhh(library(dplyr))
shhh(library(ggplot2))
shhh(library(plotly))
shhh(library(purrr))
shhh(library(DT))
shhh(library(metathis))
shhh(library(tidyr))
shhh(library(stringr))
shhh(library(reshape2))
shhh(library(rsconnect))

# Functions ---------------------------------------------------------------------------------

# Set global variables --------------------------------------------------------

site_title <- "16 to 18 Transition Matrices" # name of app
parent_pub_name <- "A level and other 16 to 18 results" # name of source publication
parent_publication <- # link to source publication
  "https://explore-education-statistics.service.gov.uk/find-statistics/a-level-and-other-16-to-18-results"

# Set the URLs that the site will be published to
site_primary <- "https://department-for-education.shinyapps.io/ks5-transition-matrices/"

# Combine URLs into list for disconnect function
# We can add further mirrors where necessary. Each one can generally handle
# about 2,500 users simultaneously
sites_list <- c(site_primary)

# Set the key for Google Analytics tracking
google_analytics_key <- "851195T40Y"
# End of global variables -----------------------------------------------------

# -----------------------------------------------------------------------------------------------------------------------------
# ---- Numbers Table from QRD filtering grades on SUBLEVNO & SUBJ & SIZE & GRADE STRUCTURE ----
# -----------------------------------------------------------------------------------------------------------------------------

# Returns a table from the Student Numbers CSV
number_select_function <- function(ReportYr_sel, qual, subj, size, grade_structure) {
  filter_selection <- paste0(qual, subj, size, grade_structure)
  qual_grades <- filter(
    grade_lookup,
    SUBLEVNO == qual & SUBJ == subj & SIZE == size & gradeStructure == grade_structure
  )

  # Grades already sorted so just need to extract list of grades
  grade_list <- qual_grades$GRADE

  table <- stud_numbers %>%
    filter(ReportYr == ReportYr_sel & QUAL_ID == filter_selection) %>%
    select(PRIOR_BAND, all_of(grade_list))

  return(table)
}

# -----------------------------------------------------------------------------------------------------------------------------
# ---- Percentages Table from QRD filtering grades on SUBLEVNO & SUBJ & SIZE & GRADE STRUCTURE ----
# -----------------------------------------------------------------------------------------------------------------------------

# Returns a table from the Student Percentages CSV
percentage_select_function <- function(ReportYr_sel, qual, subj, size, grade_structure) {
  filter_selection <- paste0(qual, subj, size, grade_structure)
  qual_grades <- filter(grade_lookup, SUBLEVNO == qual & SUBJ == subj & SIZE == size & gradeStructure == grade_structure)

  # Grades already sorted so just need to extract list of grades
  grade_list <- qual_grades$GRADE

  table <- stud_percentages %>%
    filter(ReportYr == ReportYr_sel & QUAL_ID == filter_selection) %>%
    select(PRIOR_BAND, all_of(grade_list))

  return(table)
}




















# Source scripts ---------------------------------------------------------------------------------

# Source any scripts here. Scripts may be needed to process data before it gets to the server file.
# It's best to do this here instead of the server file, to improve performance.

# source("R/filename.r")


# appLoadingCSS ----------------------------------------------------------------------------
# Set up loading screen

appLoadingCSS <- "
#loading-content {
  position: absolute;
  background: #000000;
  opacity: 0.9;
  z-index: 100;
  left: 0;
  right: 0;
  height: 100%;
  text-align: center;
  color: #FFFFFF;
}
"



# -----------------------------------------------------------------------------------------------------------------------------
# ---- Read in the Data from 01_data-processing ----
# -----------------------------------------------------------------------------------------------------------------------------


stud_numbers <- readRDS("data/all_student_numbers.rds")
stud_percentages <- readRDS("data/all_student_percentages.rds")

qual_lookup <- readRDS("data/qual_lookup.rds")
grade_lookup <- readRDS("data/grade_lookup.rds")






# -----------------------------------------------------------------------------------------------------------------------------
# ---- Prior Grade boundaries ----
# -----------------------------------------------------------------------------------------------------------------------------

grade_boundaries <- c("<1", "1-<2", "2-<3", "3-<4", "4-<5", "5-<6", "6-<7", "7-<8", "8-<9", "9>=")


# -----------------------------------------------------------------------------------------------------------------------------
# ---- Example Table ----
# -----------------------------------------------------------------------------------------------------------------------------

# Create a fixed table for example table
user_selection_example <- qual_lookup %>%
  filter(ReportYr == max(ReportYr) & Qual_Description == "GCE A level" & Subject == "Mathematics" & ASIZE == 1 & gradeStructure == "*,A,B,C,D,E") %>%
  distinct()


example_data <- number_select_function(
  user_selection_example$ReportYr, user_selection_example$SUBLEVNO, user_selection_example$SUBJ,
  user_selection_example$SIZE, user_selection_example$gradeStructure
) %>%
  rename("Prior Band" = PRIOR_BAND) %>%
  .[!sapply(., function(x) all(is.na(x) | x == ""))]


# extract the value for example
example_value <- example_data %>%
  filter(`Prior Band` == "5-<6") %>%
  pull("C")







site_primary <- "https://https://department-for-education.shinyapps.io/ks5-transition-matrices/"
# site_overflow <- "https://https://department-for-education.shinyapps.io/ks5-transition-matrices/"
sites_list <- c(site_primary) # We can add further mirrors where necessary. Each one can generally handle about 2,500 users simultaneously
ees_pub_name <- "A level and other 16 to 18 results" # Update this with your parent publication name (e.g. the EES publication)
ees_publication <- "https://explore-education-statistics.service.gov.uk/find-statistics/a-level-and-other-16-to-18-results/" # Update with parent publication link
