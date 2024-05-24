# shinytest

<!-- badges: start -->
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/shinytest)](https://www.r-pkg.org/pkg/shinytest)
[![R build status](https://github.com/rstudio/shinytest/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rstudio/shinytest/actions)
<!-- badges: end -->

NOTE: **shinytest is deprecated** and may not work with Shiny after version 1.8.1, which was released on 2024-04-02. This is because it is based on a headless browser, PhantomJS, which was last released on 2016-01-24 and is no longer being developed. Going forward, please use [shinytest2](https://github.com/rstudio/shinytest2), which makes use of headless Chromium-based browsers. See the [shinytest to shinytest2 Migration Guide](https://rstudio.github.io/shinytest2/articles/z-migration.html) for more information.

shinytest provides a simulation of a Shiny app that you can control in order to automate testing. shinytest uses a snapshot-based testing strategy: the first time it runs a set of tests for an application, it performs some scripted interactions with the app and takes one or more snapshots of the application’s state. Subsequent runs perform the same scripted interactions then compare the results; you'll get an error if they're different.

## Installation

To install the current release version:


```r
install.packages("shinytest")
```

## Usage

See the [getting started guide](https://rstudio.github.io/shinytest/articles/shinytest.html) to learn how to use shinytest.
