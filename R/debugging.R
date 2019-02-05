
sd_setupDebugging <- function(self, private, debug) {
  "!DEBUG sd_setupDebugging"
  debug <- as_debug(debug)

  if (length(debug)) {
    ## TODO: poll the logs
  }
}

sd_getDebugLog <- function(self, private, type) {
  "!DEBUG sd_getDebugLog"

  type <- as_debug(type)

  output <- list()

  # It's possible for there not to be a shinyProcess object, if we're testing
  # against a remote server (as in shinyloadtest).
  if (!is.null(private$shinyProcess) && "shiny_console" %in% type) {
    "!DEBUG sd_getDebugLog shiny_console"
    out <- readLines(private$shinyProcess$get_output_file(), warn = FALSE)
    err <- readLines(private$shinyProcess$get_error_file(), warn = FALSE)
    output$shiny_console <- make_shiny_console_log(out = out, err = err)
  }

  if ("browser" %in% type) {
    "!DEBUG sd_getDebugLog browser"
    output$browser <- make_browser_log(private$web$readLog())
  }

  if ("shinytest" %in% type) {
    "!DEBUG sd_getDebugLog shinytest log"
    output$shinytest <- make_shinytest_log(private$web$executeScript(
      "if (! window.shinytest) { return([]) }
       var res = window.shinytest.log_entries;
       window.shinytest.log_entries = [];
       return res;"
    ))
  }

  merge_logs(output)
}

sd_enableDebugLogMessages <- function(self, private, enable = TRUE) {
  private$web$executeScript(
    "window.shinytest.log_messages = arguments[0]",
    enable
  )
}

make_shiny_console_log <- function(out, err) {
  out <- data.frame(
    stringsAsFactors = FALSE,
    level = if (length(out)) "INFO" else character(),
    timestamp = if (length(out)) as.POSIXct(NA) else as.POSIXct(character()),
    message = filter_log_text(out),
    type = if (length(out)) "shiny_console" else character()
  )
  err <- data.frame(
    stringsAsFactors = FALSE,
    level = if (length(err)) "ERROR" else character(),
    timestamp = if (length(err)) as.POSIXct(NA) else as.POSIXct(character()),
    message = filter_log_text(err),
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
    # Workaround for bug in parsedate::parse_date where it errors on empty input:
    # https://github.com/gaborcsardi/parsedate/issues/20
    timestamp = if (length(entries)) parse_date(vapply(entries, "[[", "", "timestamp"))
                else as.POSIXct(character()),
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


# Remove problem characters from log text. Currently just "\f", which clears the
# console in RStudio.
filter_log_text <- function(str) {
  gsub("\f", "", str, fixed = TRUE)
}

#' @export
#' @importFrom crayon blue magenta cyan make_style

format.shinytest_logs <- function(x, ..., short = FALSE) {

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

  lines <- vapply(seq_len(nrow(x)), function(i) {

    if (short) {
      return(
        paste0(
          types[x$type[i]], "> ",
          colors[[ x$type[i] ]](x$message[i])
        )
      )
    }

    time <- if (is.na(x$timestamp[i])) {
      "-----------"
    } else {
      format(x$timestamp[i], "%H:%M:%OS2")
    }

    paste(
      sep = "",
      types[x$type[i]],
      "/",
      substr(x$level[i], 1, 1),
      " ",
      time,
      " ",
      colors[[ x$type[i] ]](x$message[i])
    )
  }, character(1))

  paste(lines, collapse = "\n")
}

#' @export
#' @importFrom crayon blue magenta cyan make_style

print.shinytest_logs <- function(x, ..., short = FALSE) {
  cat(format(x, short = short), ...)
  invisible(x)
}
