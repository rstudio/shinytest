app_save <- function(app, path = tempfile(), env = parent.frame()) {
  if (!is_installed("globals")) {
    abort(c(
      "globals package required to test app object",
      i = "Do you need to run `install.packages('globals')`"
    ))
  }

  if (!dir.exists(path)) {
    dir.create(path)
  }

  file.copy(
    system.file("app-template.R", package = "shinytest"),
    file.path(path, "app.R")
  )

  data <- app_data(app, env)
  saveRDS(data, file.path(path, "data.rds"))

  path
}

# Open questions:
# * what happen if app uses non-exported function?
app_data <- function(app, env = parent.frame()) {
  server <- app$serverFuncSource()
  globals <- app_server_globals(server, env)

  data <- globals$globals
  data$ui <- environment(app$httpHandler)$ui
  data$server <- server
  data$resources <- shiny::resourcePaths()
  data$packages <- globals$packages
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
