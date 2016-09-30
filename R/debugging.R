
app_setup_debugging <- function(self, private, debug) {
  "!DEBUG app_setup_debugging"
  debug <- assert_debug(debug)

  if (length(debug)) {
    ## TODO: poll the logs
  }
}

client_get_debug_log <- function(self, private, type) {
  "!DEBUG app_get_debug_log"

  type <- assert_debug(type)

  output <- list()

  if ("shiny_console" %in% type) {
    "!DEBUG app_get_debug_log shiny_console"
    out <- private$shiny_process$read_output_lines()
    err <- private$shiny_process$read_error_lines()
    output$shiny_console <- make_shiny_console_log(out = out, err = err)
  }

  if ("phantom_console" %in% type) {
    "!DEBUG app_get_debug_log phantom_console"
    out <- private$phantom_process$read_output_lines()
    err <- private$phantom_process$read_error_lines()
    output$phantom_console <- make_phantom_log(out = out, err = err)
  }

  if ("browser" %in% type) {
    "!DEBUG app_get_debug_log browser"
    output$browser <- make_browser_log(private$session$read_log())
  }

  if ("shinytest" %in% type) {
    "!DEBUG app_get_debug_log shinytest log"
    output$shinytest <- make_shinytest_log(private$session$execute_script(
      "if (! window.shinytest) { return([]) }
       var res = window.shinytest.log_entries;
       window.shinytest.log_entries = [];
       return res;"
    ))
  }

  merge_logs(output)
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

#' @importFrom parsedate parse_date

make_phantom_log <- function(out, err) {
  log <- c(out, err)

  ## Remove empty lines
  log <- grep("^\\s+$", log, perl = TRUE, invert = TRUE, value = TRUE)

  ## Merge indented lines to previous ones
  log <- gsub("\n\\s+", " ", paste(log, collapse = "\n"), perl = TRUE)
  log <- strsplit(log, "\n")[[1]]

  ## Parse level and time stamp
  mat <- as.data.frame(
    stringsAsFactors = FALSE,
    re_match(
      "^\\[(?<level>[^-\\s]+)[-\\s]+(?<timestamp>[^\\]]+)\\]\\s*(?<message>.*)$",
      log
    )
  )

  mat$timestamp <- parse_date(mat$timestamp)
  mat$type <- if (nrow(mat)) "phantom_console" else character()
  mat[, -1]
}

make_browser_log <- function(log) {
  log$type <- if (nrow(log)) "browser" else character()
  log[, c("level", "timestamp", "message", "type")]
}

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
  log <- log[order(log$time), ]
  class(log) <- c("shinytest_logs", class(log))
  log
}

#' @export
#' @importFrom crayon blue magenta cyan make_style

print.shinytest_logs <- function(x, ...) {

  colors <- list(
    shiny_console = magenta,
    phantom_console = make_style("darkgrey"),
    browser = cyan,
    shinytest = blue
  )

  types <- c(
    shiny_console = "C",
    phantom_console = "P",
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
