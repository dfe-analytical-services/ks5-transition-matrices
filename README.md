<h1 align="center">
  <br>
16-18 Transition Matrices App
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

This repository is for converting the KS5 transition matrices data into a dashboard format. The data underpinning this app can be found in the .outputs folder, however the syntax used to build these data is stored separately in a restricted area. Each year new outputs will be generated and pushed to this repository to reflect the new data for that academic year.



Links to where our app is deployed:

- Public - https://department-for-education.shinyapps.io/ks5-transition-matrices/
- Internal production - 
- Internal pre-production - 



---

## Requirements


### i. Software requirements (for running locally)

- Installation of R Studio 1.2.5033 or higher

- Installation of R 3.6.2 or higher

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

UI tests have been created using shinytest to that test the app loads as expected.

GitHub Actions provide CI by running the automated tests. The yaml files for these workflows can be found in the .github/workflows folder.




### Deployment

- The app is deployed to the department's shinyapps.io subscription using GitHub actions, to [https://department-for-education.shinyapps.io/ks5-transition-matrices/](https://department-for-education.shinyapps.io/ks5-transition-matrices/). The yaml file for this can be found in the .github/workflows folder.



---

## How to contribute


### Flagging issues

If you spot any issues with the application, please flag it in the "Issues" tab of this repository, and label as a bug.

### Merging pull requests

Only members of the 16-18 Accountability Data and Development team can merge pull requests. 

---

## Contact

Please contact Attainment.STATISTICS@education.gov.uk if you have any questions or feedback to share with the team.
