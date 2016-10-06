
shinyUI(pageWithSidebar(
  headerPanel(""),
  sidebarPanel(),
  mainPanel(
    tabsetPanel(
      id = "tabset1",
      tabPanel(
        "tab1",
        tabsetPanel(
          id = "tabset11",
          tabPanel("tab11"),
          tabPanel("tab12"),
          tabPanel("tab13")
        )
      ),
      tabPanel(
        "tab2",
        tabsetPanel(
          id = "tabset12",
          tabPanel("tab21", value = "xxx"),
          tabPanel("tab22"),
          tabPanel("tab23"),
          tabPanel("tab24")
        )
      )
    )
  )
))
