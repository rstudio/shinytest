# BayesianNetwork

<details>

* Version: 0.1.5
* GitHub: https://github.com/paulgovan/bayesiannetwork
* Source code: https://github.com/cran/BayesianNetwork
* Date/Publication: 2018-12-02 05:10:03 UTC
* Number of recursive dependencies: 122

Run `revdep_details(, "BayesianNetwork")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘shinytest’ ‘testthat’
      All declared Imports should be used.
    ```

# codebook

<details>

* Version: 0.9.2
* GitHub: https://github.com/rubenarslan/codebook
* Source code: https://github.com/cran/codebook
* Date/Publication: 2020-06-06 23:40:03 UTC
* Number of recursive dependencies: 209

Run `revdep_details(, "codebook")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘graphics’ ‘jsonlite’ ‘rlang’ ‘tidyselect’ ‘vctrs’
      All declared Imports should be used.
    ```

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 65 marked UTF-8 strings
    ```

# corporaexplorer

<details>

* Version: 0.8.4
* GitHub: https://github.com/kgjerde/corporaexplorer
* Source code: https://github.com/cran/corporaexplorer
* Date/Publication: 2021-03-18 02:40:02 UTC
* Number of recursive dependencies: 103

Run `revdep_details(, "corporaexplorer")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘RColorBrewer’ ‘ggplot2’ ‘rmarkdown’ ‘shinyWidgets’ ‘shinydashboard’
      ‘shinyjs’
      All declared Imports should be used.
    ```

# dqshiny

<details>

* Version: 0.0.4
* GitHub: https://github.com/daqana/dqshiny
* Source code: https://github.com/cran/dqshiny
* Date/Publication: 2020-05-10 21:20:08 UTC
* Number of recursive dependencies: 85

Run `revdep_details(, "dqshiny")` for more info

</details>

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
       6.     └─shiny:::validate_session_object(session)
      ── Error (test-paging.R:18:3): update_page works with strange inputs ───────────
      Error: `session` must be a 'ShinySession' object. Did you forget to pass `session` to `::()`?`session` must be a 'ShinySession' object. Did you forget to pass `session` to `shiny()`?`session` must be a 'ShinySession' object. Did you forget to pass `session` to `updateNumericInput()`?
      Backtrace:
          █
       1. ├─testthat::expect_equal(...) test-paging.R:18:2
       2. │ └─testthat::quasi_label(enquo(object), label, arg = "object")
       3. │   └─rlang::eval_bare(expr, quo_get_env(quo))
       4. └─dqshiny:::update_page(mtcars, 1, 200, session)
       5.   └─shiny::updateNumericInput(session, "pageNum", value = p, max = maxP)
       6.     └─shiny:::validate_session_object(session)
      
      [ FAIL 3 | WARN 0 | SKIP 8 | PASS 805 ]
      Error: Test failures
      Execution halted
    ```

# GenEst

<details>

* Version: 1.4.6
* GitHub: NA
* Source code: https://github.com/cran/GenEst
* Date/Publication: 2021-06-17 07:10:08 UTC
* Number of recursive dependencies: 89

Run `revdep_details(, "GenEst")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘htmlwidgets’
      All declared Imports should be used.
    ```

# grapesAgri1

<details>

* Version: 1.1.0
* GitHub: https://github.com/pratheesh3780/grapesAgri1
* Source code: https://github.com/cran/grapesAgri1
* Date/Publication: 2021-08-14 12:50:02 UTC
* Number of recursive dependencies: 198

Run `revdep_details(, "grapesAgri1")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘Hmisc’ ‘PairedData’ ‘RColorBrewer’ ‘agricolae’ ‘corrplot’ ‘desplot’
      ‘dplyr’ ‘ggplot2’ ‘ggpubr’ ‘gridGraphics’ ‘gtools’ ‘kableExtra’
      ‘knitr’ ‘magrittr’ ‘pastecs’ ‘reshape2’ ‘rmarkdown’ ‘shinyWidgets’
      ‘summarytools’
      All declared Imports should be used.
    ```

# jsmodule

<details>

* Version: 1.1.8
* GitHub: https://github.com/jinseob2kim/jsmodule
* Source code: https://github.com/cran/jsmodule
* Date/Publication: 2021-08-09 04:20:02 UTC
* Number of recursive dependencies: 222

Run `revdep_details(, "jsmodule")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘devEMF’ ‘survC1’
      All declared Imports should be used.
    ```

# leafdown

<details>

* Version: 1.0.0
* GitHub: NA
* Source code: https://github.com/cran/leafdown
* Date/Publication: 2021-04-29 07:30:03 UTC
* Number of recursive dependencies: 105

Run `revdep_details(, "leafdown")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘R6’ ‘shiny’ ‘shinyjs’
      All declared Imports should be used.
    ```

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 75 marked UTF-8 strings
    ```

# mlr3shiny

<details>

* Version: 0.1.1
* GitHub: NA
* Source code: https://github.com/cran/mlr3shiny
* Date/Publication: 2020-03-31 10:30:02 UTC
* Number of recursive dependencies: 133

Run `revdep_details(, "mlr3shiny")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘DT’ ‘data.table’ ‘e1071’ ‘mlr3’ ‘mlr3learners’ ‘mlr3measures’ ‘plyr’
      ‘purrr’ ‘ranger’ ‘readxl’ ‘shinyWidgets’ ‘shinyalert’
      ‘shinydashboard’ ‘shinyjs’ ‘shinythemes’ ‘stats’ ‘stringr’
      All declared Imports should be used.
    ```

# mmaqshiny

<details>

* Version: 1.0.0
* GitHub: https://github.com/meenakshi-kushwaha/mmaqshiny
* Source code: https://github.com/cran/mmaqshiny
* Date/Publication: 2020-06-26 16:00:23 UTC
* Number of recursive dependencies: 132

Run `revdep_details(, "mmaqshiny")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 15.6Mb
      sub-directories of 1Mb or more:
        images   1.1Mb
        shiny   14.5Mb
    ```

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘Cairo’ ‘DT’ ‘XML’ ‘caTools’ ‘data.table’ ‘dplyr’ ‘ggplot2’
      ‘htmltools’ ‘leaflet’ ‘lubridate’ ‘plotly’ ‘shinyjs’ ‘stringr’ ‘xts’
      ‘zoo’
      All declared Imports should be used.
    ```

# oolong

<details>

* Version: 0.4.0
* GitHub: https://github.com/chainsawriot/oolong
* Source code: https://github.com/cran/oolong
* Date/Publication: 2021-05-31 14:20:02 UTC
* Number of recursive dependencies: 150

Run `revdep_details(, "oolong")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘R6’ ‘dplyr’ ‘miniUI’ ‘text2vec’
      All declared Imports should be used.
    ```

# plotly

<details>

* Version: 4.9.4.1
* GitHub: https://github.com/ropensci/plotly
* Source code: https://github.com/cran/plotly
* Date/Publication: 2021-06-18 09:00:02 UTC
* Number of recursive dependencies: 154

Run `revdep_details(, "plotly")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  6.7Mb
      sub-directories of 1Mb or more:
        htmlwidgets   3.8Mb
    ```

# safetyGraphics

<details>

* Version: 1.1.0
* GitHub: https://github.com/SafetyGraphics/safetyGraphics
* Source code: https://github.com/cran/safetyGraphics
* Date/Publication: 2020-01-15 22:50:05 UTC
* Number of recursive dependencies: 113

Run `revdep_details(, "safetyGraphics")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘shinybusy’
      All declared Imports should be used.
    ```

# shiny

<details>

* Version: 1.6.0
* GitHub: https://github.com/rstudio/shiny
* Source code: https://github.com/cran/shiny
* Date/Publication: 2021-01-25 21:50:02 UTC
* Number of recursive dependencies: 104

Run `revdep_details(, "shiny")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 12.2Mb
      sub-directories of 1Mb or more:
        R     2.1Mb
        www   8.8Mb
    ```

# spotGUI

<details>

* Version: 0.2.3
* GitHub: NA
* Source code: https://github.com/cran/spotGUI
* Date/Publication: 2021-03-30 17:50:02 UTC
* Number of recursive dependencies: 162

Run `revdep_details(, "spotGUI")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘batchtools’
      All declared Imports should be used.
    ```

# tidycells

<details>

* Version: 0.2.2
* GitHub: https://github.com/r-rudra/tidycells
* Source code: https://github.com/cran/tidycells
* Date/Publication: 2020-01-09 19:10:09 UTC
* Number of recursive dependencies: 126

Run `revdep_details(, "tidycells")` for more info

</details>

## In both

*   checking examples ... ERROR
    ```
    ...
      8. │ └─`%>%`(...)
      9. ├─tidycells::as_cell_df(.)
     10. ├─tidycells:::as_cell_df.data.frame(.)
     11. │ └─d %>% attach_intermediate_class() %>% as_cell_df_internal(...)
     12. ├─tidycells:::as_cell_df_internal(., ...)
     13. ├─tidycells:::as_cell_df_internal.unpivotr(., ...)
     14. │ └─`%>%`(...)
     15. ├─dplyr::distinct(., row, col, data_type, value)
     16. ├─dplyr::filter(., !is.na(value))
     17. ├─dplyr::mutate(...)
     18. ├─dplyr::mutate(...)
     19. └─dplyr:::mutate.data.frame(...)
     20.   ├─dplyr::dplyr_col_modify(.data, cols)
     21.   └─dplyr:::dplyr_col_modify.data.frame(.data, cols)
     22.     ├─base::as.list(dplyr_vec_data(data))
     23.     └─dplyr:::dplyr_vec_data(data)
     24.       └─vctrs::vec_data(x)
     25.         └─vctrs::vec_assert(x)
     26.           └─vctrs:::stop_scalar_type(x, arg)
     27.             └─vctrs:::stop_vctrs(msg, "vctrs_error_scalar_type", actual = x)
    Execution halted
    ```

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
       16. │   │   ├─row.names %||% .row_names_info(x, type = 0L)
       17. │   │   └─base::.row_names_info(x, type = 0L)
       18. │   └─vctrs::vec_slice(data, i)
       19. └─vctrs:::stop_scalar_type(...)
       20.   └─vctrs:::stop_vctrs(msg, "vctrs_error_scalar_type", actual = x)
      ── Failure (test-read_cells_real.R:12:3): read_cells on real data works I ──────
      unique(dcpi$minor_2) not equal to "Year/Month".
      target is NULL, current is character
      ── Failure (test-read_cells_real.R:14:3): read_cells on real data works I ──────
      dcpi$major_2 %>% unique() %>% tolower() %>% sort() not equal to month.abb %>% tolower() %>% sort().
      Lengths differ: 0 is not 12
      
      [ FAIL 25 | WARN 39 | SKIP 4 | PASS 34 ]
      Error: Test failures
      Execution halted
    ```

