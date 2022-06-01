# File for storing the text content  of the app

# Information text =========================================================================================

info_text <- function() {
  div(
    "Transition matrices are a useful tool to help visualise the progression of pupils aged 16-18 from key stage 4 (KS4) to key stage 5 (KS5).",
    br(),
    br(),
    "To use the transition matrices please select a qualification, subject and subject size from the dropdown boxes found in the left panel. 
    Use the Number of Pupils, and Percentage of Pupils tabs on the left to view the respective tables. A graphical representaion of the percentage 
    data can also be viewed within the Percentage of Pupils tab, and an additional dropdown box is available to select the required prior attainment band. 
    The tabular data from each table can be downloaded in csv format using the download button on each page.",
    br(),
    br(),
    h2("Example Transition Matrices"),
    "Below is an example transition matrix. It shows the national attainment of GCE A level mathematics students at KS5 based on their average KS4 attainment."
  )
}


