# Wait a little bit before init'ing a new ShinyDriver instance
# Help deter random phantomjs shutdowns on GHA
sleep_on_ci <- function() {
  on_ci <- isTRUE(as.logical(Sys.getenv("CI")))
  if (on_ci) {
    Sys.sleep(1)
  }
}
