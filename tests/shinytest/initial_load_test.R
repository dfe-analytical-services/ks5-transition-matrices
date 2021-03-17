
#library(shiny)


# Initialize a ShinyDriver object using the app (point to the right directory)
app <- ShinyDriver$new("../../")
app$snapshotInit("initial_load_test", screenshot = FALSE)

# 1. Does it load  -------------------------------------------------------------------------------------------------------------------
app$snapshot()





