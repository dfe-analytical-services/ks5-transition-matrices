source("renv/activate.R")


tidy_code <- function() {
  source("global.r")
  tidy_code_function()
}

# Function to run tests
run_tests_locally <- function() {
  Sys.unsetenv("http_proxy")
  Sys.unsetenv("https_proxy")
  source("global.r")
  # message("================================================================================")
  # message("== testthat ====================================================================")
  # message("")
  # testthat::test_dir("tests/testthat")
  # message("")
  message("================================================================================")
  message("== shinytest ===================================================================")
  message("")
  shinytest::testApp()
  message("")
  message("================================================================================")
}
