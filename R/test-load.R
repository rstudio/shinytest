

#' Run load tests for a Shiny application
#'
#' @param testFile The file containing a test script to run. Test script can be
#'   generated from recordTest(load_mode = TRUE).
#' @param numConcurrent Number of concurrent connections to simulate.
#' @param numTotal Total number of connections to simulation.
#' @param url Web address of the deployed Shiny application.
#'
#' @details This function simulates load against a deployed application. The
#'   function creates a cluster of workers using the parallel function
#'   makePSOCKcluster. The number of works is equal to the number of desired
#'   concurrent connections. Each worker launches a phantomJS process that calls
#'   the URL and drives the app through the test. Test should be generated using
#'   the recordTest function load_mode = TRUE. Timing information is aggregated
#'   and returned as a data frame. If the number of total tests > number of
#'   concurrent tests, then as workers finish their tests they will start a new
#'   test. The phantomJS process is recycled, but a new browser session is
#'   started for each test.
#'
#' @importFrom foreach %dopar% foreach
#'
#' @export
loadTest <- function(testFile = "./tests/myloadtest.R",
                     numConcurrent = 4,
                     numTotal = 8,
                     url = NULL) {

  # TODO Validate File Input

  if (!grepl("^http(s?)://", url))
    stop(paste0("URL ", url," does not appear to be for a deployed Shiny app"))


  ## Validate Inputs
  assert_that(is_count(numConcurrent))
  assert_that(is_count(numTotal))
  if (numTotal == 0 || numConcurrent == 0)
    stop("numTotal and numConcurrent must be >= 1")

  if (numTotal < numConcurrent)
    stop("numTotal must be >= numConcurrent")


  ## Create Workers
  message(paste0('=======Initializing PSOCK Cluster with ',
    numConcurrent, ' Workers ========'))

  ## Validate Required Packages
  if (!requireNamespace("doParallel", quietly = TRUE))
    stop("doParallel needed for this function to work. Please install it.",
         call. = FALSE)

  if (!requireNamespace("foreach", quietly = TRUE))
    stop("foreach needed for this function to work. Please install it.",
         call. = FALSE)


  cl <- parallel::makePSOCKcluster(numConcurrent)
  on.exit(parallel::stopCluster(cl))
  doParallel::registerDoParallel(cl)

  ## Loop Through Connections
  results <- foreach::foreach(i = 1:numTotal) %dopar% {
    withr::with_options(
      list(target.url = url, connection.id = i), {
      source(testFile)
    })
  }

  results <- do.call(rbind, lapply(results, data.frame, stringsAsFactors = FALSE))
  results
}