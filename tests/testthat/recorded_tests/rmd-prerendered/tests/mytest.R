app <- ShinyDriver$new("../doc.Rmd", seed = 4938)
app$snapshotInit("mytest")

app$snapshot()
app$setInputs(n_breaks = "35")
app$setInputs(bw_adjust = 1.8)
app$snapshot()

rmarkdown::shiny_prerendered_clean("../doc.Rmd")