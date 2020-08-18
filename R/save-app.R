app_save <- function(app, env = parent.frame()) {
  app_dir <- tempfile()
  dir.create(app_dir)

  file.copy(
    system.file("app-template.R", package = "shinytest"),
    file.path(app_dir, "app.R")
  )

  data <- app_data(app, env)
  saveRDS(data, file.path(app_dir, "data.rds"))

  app_dir
}

app_data <- function(app, env = parent.frame()) {
  server <- app$serverFuncSource()
  globals <- app_server_globals(server, env)

  data <- globals$globals
  data$`_ui` <- environment(app$httpHandler)$ui
  data$`_server` <- server
  data$`_resources` <- resource_paths_get()
  data$`_packages` <- globals$packages
  data
}

app_server_globals <- function(server, env = parent.frame()) {
  # Work around for https://github.com/HenrikBengtsson/globals/issues/61
  env <- new.env(parent = env)
  env$output <- NULL

  globals <- globals::globalsOf(server, envir = env, recursive = FALSE)
  globals <- globals::cleanup(globals)

  # remove globals found in packages
  pkgs <- globals::packagesOf(globals)
  in_package <- vapply(
    attr(globals, "where"),
    function(x) !is.null(attr(x, "name")),
    logical(1)
  )
  globals <- globals[!in_package]
  attributes(globals) <- list(names = names(globals))

  # https://github.com/HenrikBengtsson/globals/issues/61
  globals$output <- NULL

  list(
    globals = globals,
    packages = pkgs
  )
}

resource_paths_get <- function() {
  resources <- getNamespace("shiny")$.globals$resources
  vapply(resources, "[[", "directoryPath", FUN.VALUE = character(1))
}
