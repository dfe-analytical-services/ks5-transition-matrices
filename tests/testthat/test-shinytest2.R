library(shinytest2)
library(diffviewer)

test_that("{shinytest2} recording: ks5-transition-matrices", {
  app <- AppDriver$new(
    test_path("../.."),
    name = "ks5-transition-matrices",
    height = 846, width = 1445,
    load_timeout = 45 * 1000,
    timeout = 20 * 1000,
    wait = TRUE # ,
    # variant = platform_variant()
  )
  app$wait_for_idle()

  app$set_inputs(
    cookies = c("GA1.1.1784488804.1728980230", "GS1.1.1729152208.1.1.1729152369.0.0.0"),
    allow_no_input_binding_ = TRUE
  )

  app$wait_for_idle()
  app$expect_values() # 1

  app$click("support")
  app$wait_for_idle()
  app$expect_values() # 2

  app$click("accessibility_statement")
  app$wait_for_idle()
  app$expect_values() # 3

  app$click("cookies_statement")
  app$wait_for_idle()
  app$expect_values() # 4

  app$click("cookies_to_dashboard")
  app$wait_for_idle()
  app$expect_values() # 5

  app$set_inputs(navlistPanel = "dashboard", wait_ = FALSE)
  app$wait_for_idle()
  app$expect_values() # 6

  app$set_inputs(format = "Percentage data", wait_ = FALSE)
  app$wait_for_idle()
  Sys.sleep(5)
  app$expect_values() # 7

  app$set_inputs(subj_select = "Chemistry", wait_ = FALSE)
  app$wait_for_idle()
  app$set_inputs(format = "Numbers data", wait_ = FALSE)
  app$wait_for_idle()
  app$expect_values() # 8

  app$set_inputs(format = "Percentage data", wait_ = FALSE)
  app$wait_for_idle()
  Sys.sleep(5)
  app$expect_values() # 9

  # app$set_inputs(chart_band = "4-<5", wait_ = FALSE)
  # app$wait_for_idle()
  # Sys.sleep(5)
  # app$expect_screenshot() # 10

  app$set_inputs(qual_select = "VRQ Level 3", wait_ = FALSE)
  app$wait_for_idle()
  app$set_inputs(subj_select = "Health Studies", wait_ = FALSE)
  app$wait_for_idle()
  app$set_inputs(size_select = "3.25", wait_ = FALSE)
  app$wait_for_idle()
  app$set_inputs(format = "Numbers data", wait_ = FALSE)
  app$wait_for_idle()
  app$expect_values() # 11

  app$set_inputs(format = "Percentage data", wait_ = FALSE)
  app$wait_for_idle()
  Sys.sleep(5)
  app$expect_values() # 12

  # app$set_inputs(chart_band = "5-<6", wait_ = FALSE)
  # app$wait_for_value(output = "percentage_chart")
  # Sys.sleep(5)
  # app$expect_screenshot() # 13
})
