## Comments

#### 2021-08-20

Bug fixes.

I have removed the `LazyData` field in the DESCRIPTION to address the NOTE:
```
Check: LazyData
Result: NOTE
     'LazyData' is specified without a 'data' directory
```

Thank you,
Winston


## Test environments and R CMD check results

* GitHub Actions - https://github.com/rstudio/shinytest/pull/404/checks
  * macOS
    * devel, release
  * windows
    * release, 3.6
  * ubuntu20
    * devel, release, oldrel/1, oldrel/2, oldrel/3, oldrel/4
* devtools::
  * check_win_devel()
  * check_win_release()
  * check_win_oldrelease()

0 errors ✔ | 0 warnings ✔ | 0 notes ✔


## revdepcheck results

We checked 31 reverse dependencies (30 from CRAN + 1 from BioConductor), comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages
