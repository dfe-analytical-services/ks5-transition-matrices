library(shinytest2)

test_that("{shinytest2} recording: ks5-transition-matrices", {
  app <- AppDriver$new(name = "ks5-transition-matrices", height = 911, width = 1619)
  app$set_inputs(
    cookies = c("GA1.1.1784488804.1728980230", "GS1.1.1729152208.1.1.1729152369.0.0.0"),
    allow_no_input_binding_ = TRUE
  )
  app$expect_values()

  app$set_inputs(example_table_rows_current = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10), allow_no_input_binding_ = TRUE)
  app$expect_values()

  app$set_inputs(example_table_rows_all = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10), allow_no_input_binding_ = TRUE)
  app$expect_values()

  app$set_inputs(example_table_state = c(
    1729152370040, 0, 10, "", TRUE, FALSE, TRUE,
    c(TRUE, "", TRUE, FALSE, TRUE), c(TRUE, "", TRUE, FALSE, TRUE), c(
      TRUE, "",
      TRUE, FALSE, TRUE
    ), c(TRUE, "", TRUE, FALSE, TRUE), c(
      TRUE, "", TRUE, FALSE,
      TRUE
    ), c(TRUE, "", TRUE, FALSE, TRUE), c(TRUE, "", TRUE, FALSE, TRUE),
    c(TRUE, "", TRUE, FALSE, TRUE), c(TRUE, "", TRUE, FALSE, TRUE)
  ), allow_no_input_binding_ = TRUE)
  app$expect_values()

  app$set_inputs(navlistPanel = "dashboard")
  app$expect_values()

  app$set_inputs(tm_table_rows_current = c(1, 2, 3, 4, 5, 6, 7, 8), allow_no_input_binding_ = TRUE)
  app$expect_values()

  app$set_inputs(tm_table_rows_all = c(1, 2, 3, 4, 5, 6, 7, 8), allow_no_input_binding_ = TRUE)
  app$expect_values()

  app$set_inputs(tm_table_state = c(
    1729152378179, 0, 10, "", TRUE, FALSE, TRUE,
    c(TRUE, "", TRUE, FALSE, TRUE), c(TRUE, "", TRUE, FALSE, TRUE), c(
      TRUE, "",
      TRUE, FALSE, TRUE
    ), c(TRUE, "", TRUE, FALSE, TRUE), c(
      TRUE, "", TRUE, FALSE,
      TRUE
    ), c(TRUE, "", TRUE, FALSE, TRUE), c(TRUE, "", TRUE, FALSE, TRUE),
    c(TRUE, "", TRUE, FALSE, TRUE)
  ), allow_no_input_binding_ = TRUE)
  app$expect_values()

  app$set_inputs(navlistPanel = "Accessibility")
  app$expect_values()

  app$set_inputs(navlistPanel = "support_panel")
  app$expect_values()

  app$set_inputs(navlistPanel = "cookies_panel_ui")
  app$expect_values()

  app$set_inputs(navlistPanel = "dashboard")
  app$expect_values()

  app$set_inputs(subj_select = "Chemistry")
  app$expect_values()

  app$set_inputs(tm_table_rows_current = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10), allow_no_input_binding_ = TRUE)
  app$expect_values()

  app$set_inputs(tm_table_rows_all = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10), allow_no_input_binding_ = TRUE)
  app$expect_values()

  app$set_inputs(tm_table_state = c(
    1729152396312, 0, 10, "", TRUE, FALSE, TRUE,
    c(TRUE, "", TRUE, FALSE, TRUE), c(TRUE, "", TRUE, FALSE, TRUE), c(
      TRUE, "",
      TRUE, FALSE, TRUE
    ), c(TRUE, "", TRUE, FALSE, TRUE), c(
      TRUE, "", TRUE, FALSE,
      TRUE
    ), c(TRUE, "", TRUE, FALSE, TRUE), c(TRUE, "", TRUE, FALSE, TRUE),
    c(TRUE, "", TRUE, FALSE, TRUE)
  ), allow_no_input_binding_ = TRUE)
  app$expect_values()

  app$set_inputs(format = "Percentage data")
  app$expect_values()

  app$set_inputs(tm_table_rows_current = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10), allow_no_input_binding_ = TRUE)
  app$expect_values()

  app$set_inputs(tm_table_rows_all = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10), allow_no_input_binding_ = TRUE)
  app$expect_values()

  app$set_inputs(tm_table_state = c(
    1729152401377, 0, 10, "", TRUE, FALSE, TRUE,
    c(TRUE, "", TRUE, FALSE, TRUE), c(TRUE, "", TRUE, FALSE, TRUE), c(
      TRUE, "",
      TRUE, FALSE, TRUE
    ), c(TRUE, "", TRUE, FALSE, TRUE), c(
      TRUE, "", TRUE, FALSE,
      TRUE
    ), c(TRUE, "", TRUE, FALSE, TRUE), c(TRUE, "", TRUE, FALSE, TRUE),
    c(TRUE, "", TRUE, FALSE, TRUE)
  ), allow_no_input_binding_ = TRUE)
  app$expect_values()

  app$set_inputs(chart_band = "4-<5")
  app$expect_values()
})
