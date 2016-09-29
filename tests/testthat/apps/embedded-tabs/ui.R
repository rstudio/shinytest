
shinyUI(pageWithSidebar(
  headerPanel(""),
  sidebarPanel(),
  mainPanel(
    tabsetPanel(
      tabPanel(
        "tab1",
        tabsetPanel(
          tabPanel("tab11"),
          tabPanel("tab12"),
          tabPanel("tab13")
        )
      ),
      tabPanel(
        "tab2",
        tabsetPanel(
          id = "tab22",
          tabPanel("tab21", value = "xxx"),
          tabPanel("tab22"),
          tabPanel("tab23"),
          tabPanel("tab24")
        )
      )
    )
  )
))
