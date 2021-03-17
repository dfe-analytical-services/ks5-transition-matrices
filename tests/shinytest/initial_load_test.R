# app <- ShinyDriver$new("../../")
# app$snapshotInit("initial_load_test", screenshot = FALSE)
# 
# app$snapshot()



app <- ShinyDriver$new("../../")
app$snapshotInit("initial_load_test", screenshot = FALSE)

# 1. Does it load  -------------------------------------------------------------------------------------------------------------------
app$snapshot()