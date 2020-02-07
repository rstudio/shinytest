app <- ShinyDriver$new("../")
app$snapshotInit("mytest")

# Check the box to display the slider and plot
app$setInputs(chkbx = TRUE)

# Wait until `input$bins` is not `NULL`
app$waitForValue("bins", ignore = list(NULL))
# Wait until `output$distPlot` is not `NULL`
# Store the retrieved plot value
priorPlotValue <- app$waitForValue("distPlot", iotype = "output", ignore = list(NULL))

app$snapshot()


# Change slider value
app$setInputs(bins = 40, wait_ = FALSE, values_=FALSE)
app$waitForValue("distPlot", iotype = "output", ignore = list(priorPlotValue))

app$snapshot()
