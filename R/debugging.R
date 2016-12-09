
app_setup_debugging <- function(self, private, debug) {
  "!DEBUG app_setup_debugging"
  debug <- as_debug(debug)

  if (length(debug)) {
    ## TODO: poll the logs
  }
}

app_getDebugLog <- function(self, private, type) {
  "!DEBUG app_getDebugLog"

  type <- as_debug(type)

  output <- list()

  if ("shiny_console" %in% type) {
    "!DEBUG app_getDebugLog shiny_console"
    out <- private$shiny_process$read_output_lines()
    err <- private$shiny_process$read_error_lines()
    output$shiny_console <- make_shiny_console_log(out = out, err = err)
  }

  if ("browser" %in% type) {
    "!DEBUG app_getDebugLog browser"
    output$browser <- make_browser_log(private$web$read_log())
  }

  if ("shinytest" %in% type) {
    "!DEBUG app_getDebugLog shinytest log"
    output$shinytest <- make_shinytest_log(private$web$execute_script(
      "if (! window.shinytest) { return([]) }
       var res = window.shinytest.log_entries;
       window.shinytest.log_entries = [];
       return res;"
    ))
  }

  merge_logs(output)
}

app_enableDebugLogMessages <- function(self, private, enable = TRUE) {
  private$web$execute_script(
    "window.shinytest.log_messages = arguments[0]",
    enable
  )
}

make_shiny_console_log <- function(out, err) {
  out <- data.frame(
    stringsAsFactors = FALSE,
    level = if (length(out)) "INFO" else character(),
    timestamp = if (length(out)) as.POSIXct(NA) else as.POSIXct(character()),
    message = out,
    type = if (length(out)) "shiny_console" else character()
  )
  err <- data.frame(
    stringsAsFactors = FALSE,
    level = if (length(err)) "ERROR" else character(),
    timestamp = if (length(err)) as.POSIXct(NA) else as.POSIXct(character()),
    message = err,
    type = if (length(err)) "shiny_console" else character()
  )
  rbind(out, err)
}

make_browser_log <- function(log) {
  log$type <- if (nrow(log)) "browser" else character()
  log[, c("level", "timestamp", "message", "type")]
}

#' @importFrom parsedate parse_date

make_shinytest_log <- function(entries) {
  data.frame(
    stringsAsFactors = FALSE,
    level = if (length(entries)) "INFO" else character(),
    timestamp = parse_date(vapply(entries, "[[", "", "timestamp")),
    message = vapply(entries, "[[", "", "message"),
    type = if (length(entries)) "shinytest" else character()
  )
}

merge_logs <- function(output) {
  log <- do.call(rbind, output)
  log <- log[order(log$timestamp), ]
  class(log) <- c("shinytest_logs", class(log))
  log
}

#' @export
#' @importFrom crayon blue magenta cyan make_style

print.shinytest_logs <- function(x, ...) {

  colors <- list(
    shiny_console = magenta,
    browser = cyan,
    shinytest = blue
  )

  types <- c(
    shiny_console = "C",
    browser = "B",
    shinytest = "S"
  )

  for (i in seq_len(nrow(x))) {

    time <- if (is.na(x$timestamp[i])) {
      "-----------"
    } else {
      format(x$timestamp[i], "%H:%M:%OS2")
    }

    cat(
      sep = "",
      types[x$type[i]],
      "/",
      substr(x$level[i], 1, 1),
      " ",
      time,
      " ",
      colors[[ x$type[i] ]](x$message[i]),
      "\n"
    )
  }

  invisible(x)
}
