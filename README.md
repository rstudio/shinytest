# shinytest

<!-- badges: start -->
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/shinytest)](https://www.r-pkg.org/pkg/shinytest)
[![R build status](https://github.com/rstudio/shinytest/workflows/R-CMD-check/badge.svg)](https://github.com/rstudio/shinytest/actions)
[![RStudio community](https://img.shields.io/badge/community-shinytest-blue?style=social&logo=rstudio&logoColor=75AADB)](https://community.rstudio.com/tags/c/shiny/8/shinytest)
<!-- badges: end -->

shinytest provides a simulation of a Shiny app that you can control in order to automate testing. shinytest uses a snapshot-based testing strategy: the first time it runs a set of tests for an application, it performs some scripted interactions with the app and takes one or more snapshots of the application’s state. Subsequent runs perform the same scripted interactions then compare the results; you'll get an error if they're different.

## Installation

To install the current release version:


```r
install.packages("shinytest")
```

## Usage

See the [getting started guide](https://rstudio.github.io/shinytest/articles/shinytest.html) to learn how to use shinytest.
