source("global.R")
source("server.R")
source("ui.R")

# options(shiny.autoload.r = FALSE)
# source('./R/03_tm_functions.R')
# source('./R/05_app_text.R')

shinyApp(ui = ui, server = server) 

