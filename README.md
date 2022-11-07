<h1 align="center">
  <br>
16-18 Transition Matrices dashboard
  <br>
</h1>

<p align="center">
  <a href="#introduction">Introduction</a> |
  <a href="#requirements">Requirements</a> |
  <a href="#how-to-use">How to use</a> |
  <a href="#how-to-contribute">How to contribute</a> |
  <a href="#contact">Contact</a>
</p>

---

## Introduction 

The 16-18 Transition matrices (TMs) are a useful tool to help visualise the progression of pupils aged 16-18 from key stage 4 (KS4) to key stage 5 (KS5).

Given the range of examinations available at 16-18, the TMs are broken down by qualification name, subject, size and grading structure. The user can use the drop down boxes to make their selection and the dashboard will present these data in two formats: 

  -	<b> Student Numbers:</b>  This table displays the number of pupils who studied the selected qualification, subject, size and grading structure, and how their grades at KS5 compares to their average KS4 attainment.

  -  <b> Student Percentages:</b>  As above, but with percentage data. An additional drop down box and chart will appear here when percentage data is selected. The prior attainment drop down box can be used to update the chart.

Notes:

  Data can be viewed in the format of a table for numbers data, or a table and chart for percentage data. Figures are available at national (England) level only.


---

## Requirements

### i. Software requirements (for running locally)

- Installation of R Studio 2022.07.2+576 or higher

- Installation of R 4.2.2 or higher

- Installation of RTools40 or higher

### ii. Programming skills required (for editing or troubleshooting)

- R at an intermediate level, [DfE R training guide](https://dfe-analytical-services.github.io/r-training-course/)

- Particularly [R Shiny](https://shiny.rstudio.com/)

---

## How to use

### Running the app locally

1. Clone or download the repo. 

2. Open the R project in R Studio.

3. Run `renv::restore()` to install dependencies.

4. Run `shiny::runApp()` to run the app locally.


### Packages

Package control is handled using renv. As in the steps above, you will need to run `renv::restore()` if this is your first time using the project.

### Tests

UI tests have been created using shinytest that check the app loads, that content appears correctly when different inputs are selected, and that tab content displays as expected. More should be added over time as extra features are added.

GitHub Actions provide CI by running the automated tests and checks for code styling. The yaml files for these workflows can be found in the .github/workflows folder.

The function run_tests_locally() is created in the Rprofile script and is available in the RStudio console at all times to run both the unit and ui tests.


### Deployment

- The app is deployed to the department's shinyapps.io subscription using GitHub actions. The yaml file for this can be found in the .github/workflows folder.


### Navigation

In general all .r files will have a usable outline, so make use of that for navigation if in RStudio: `Ctrl-Shift-O`.


### Code styling 

The function tidy_code() is created in the Rprofile script and therefore is always available in the RStudio console to tidy code according to tidyverse styling using the styler package. This function also helps to test the running of the code and for basic syntax errors such as missing commas and brackets.


---

## How to contribute

### Flagging issues

If you spot any issues with the application, please flag it in the "Issues" tab of this repository, and label as a bug.

### Merging pull requests

Only members of the 16-18 accountability data and development team can merge pull requests. Add katie-aisling as a requested reviewer, and the team will review before merging.

---

## Contact

Email
Attainment.STATISTICS@education.gov.uk