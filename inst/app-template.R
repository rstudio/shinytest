library(shiny)
attach(readRDS('data.rds'))

lapply(`_packages`, library, character.only = TRUE)
for (prefix in names(`_resources`)) {
  shiny::addResourcePath(prefix, resources[[prefix]])
}

shinyApp(`_ui`, `_server`)
