app <- ShinyDriver$new("../doc.Rmd", seed = 4323)
app$snapshotInit("mytest")
Sys.sleep(4) # Wait for a bit to render document

app$setInputs(n_breaks = "20")
app$setInputs(bw_adjust = 1)
app$snapshot()
app$setInputs(n_breaks = "35")
app$setInputs(bw_adjust = 1.8)
app$snapshot()
