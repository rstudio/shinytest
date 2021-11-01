pak::local_install(".")

# Install phantom
if (!shinytest::dependenciesInstalled()) {
  shinytest::installDependencies()
}
