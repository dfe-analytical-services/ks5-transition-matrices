# ---------------------------------------------------------
# This is the ui file.
# Use it to call elements created in your server file into the app, and define where they are placed.
# Also use this file to define inputs.
#
# Every UI file should contain:
# - A title for the app
# - A call to a CSS file to define the styling
# - An accessibility statement
# - Contact information
#
# Other elements like charts, navigation bars etc. are completely up to you to decide what goes in.
# However, every element should meet accessibility requirements and user needs.
#
# This file uses a slider input, but other inputs are available like date selections, multiple choice dropdowns etc.
# Use the shiny cheatsheet to explore more options: https://shiny.rstudio.com/images/shiny-cheatsheet.pdf
#
# Likewise, this template uses the navbar layout.
# We have used this as it meets accessibility requirements, but you are free to use another layout if it does too.
#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# ---------------------------------------------------------

#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# The documentation for this GOVUK components can be found at:
#
#    https://github.com/moj-analytical-services/shinyGovstyle
#


#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# The documentation for this GOVUK components can be found at:
#
#    https://github.com/moj-analytical-services/shinyGovstyle
#



ui <- function(input, output, session) {
  fluidPage(
    title = tags$head(
      tags$link(
        rel = "shortcut icon",
        href = "dfefavicon.png"
      ),
      # Add title for browser tabs
      tags$title(site_title)
    ),
    tags$html(lang = "en"),
    # Add meta description for search engines
    meta() %>%
      meta_general(
        application_name = site_title,
        description = site_title,
        robots = "index,follow",
        generator = "R-Shiny",
        subject = "16 to 18 statistics",
        rating = "General",
        referrer = "no-referrer"
      ),
    shinyjs::useShinyjs(),
    dfeshiny::custom_disconnect_message(
      publication_name = parent_pub_name,
      publication_link = parent_publication
    ),
    tags$head(includeHTML(("google-analytics.html"))),
    tags$head(
      tags$link(
        rel = "stylesheet",
        type = "text/css",
        href = "dfe_shiny_gov_style.css"
      )
    ),
    dfe_cookies_script(),
    cookies_banner_ui(name = "16 to 18 Transition Matrices"),
    shinyGovstyle::header(
      main_text = "",
      main_link = "https://www.gov.uk/government/organisations/department-for-education",
      secondary_text = "16 to 18 Transition Matrices",
      logo = "images/DfE_logo_landscape.png",
      logo_width = 150,
      logo_height = 32
    ),
    shinyGovstyle::banner(
      "beta banner",
      "beta",
      paste0(
        "This Dashboard is in beta phase and we are still reviewing performance and reliability. "
      )
    ),
    shiny::navlistPanel(
      "",
      id = "navlistPanel",
      widths = c(2, 8),
      well = FALSE,
      homepage_panel(),
      dashboard_panel(),
      accessibility_panel(),
      shiny::tabPanel(
        value = "support_panel",
        "Support and feedback",
        support_panel(
          team_email = "attainment.statistics@education.gov.uk",
          repo_name = "https://github.com/dfe-analytical-services/ks5-transition-matrices/",
          publication_name = "A level and other 16 to 18 results",
          publication_slug = "a-level-and-other-16-to-18-results"
        )
      ),
      shiny::tabPanel(
        value = "cookies_panel_ui",
        "Cookies",
        cookies_panel_ui(google_analytics_key = google_analytics_key)
      )
    ),
    tags$script(
      src = "script.js"
    ),
    footer(full = TRUE)
  )
}
