library(shiny)
`_data` <- readRDS('data.rds')

lapply(`_data`$packages, library, character.only = TRUE)
for (prefix in names(`_data`$resources)) {
  shiny::addResourcePath(prefix, `_data`$resources[[prefix]])
}

shinyApp(`_data`$ui, `_data`$server)
