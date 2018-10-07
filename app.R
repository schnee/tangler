#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(dplyr)
library(plotly)

devtools::load_all()

update_edgelist()

graph <- build_graph()

the_choices <-
  graph %>% activate(nodes) %>% arrange(desc(centrality)) %>% pull(name)

# Define UI for application that draws a histogram
ui <- fluidPage(titlePanel("The Tangled Web Visualizer"),
                # Sidebar with a slider input for number of bins
                sidebarLayout(sidebarPanel((
                  selectInput("node_name",
                              "Name of the Node (Ordered by Importance)",
                              choices = the_choices)
                )),
                mainPanel(
                  tabsetPanel(
                    type = "tabs",
                    tabPanel("Aesthetic", plotOutput("localWeb", height = "800px")),
                    tabPanel("Interactive", plotlyOutput("local_plotly", height = "800px"))
                  )
                )))

# Define server logic required to draw a histogram
server <- function(input, output) {
  local_graph <- reactive({
    get_local_graph(graph, input$node_name)
  })
  local_layout <- reactive({
    get_local_layout(local_graph())
  })

  output$localWeb <- renderPlot({
    get_local_plot(local_graph(), local_layout(), input$node_name)
  })

  output$local_plotly <- renderPlotly({
    get_local_plotly(local_graph(), local_layout())
  })
}

# Run the application
shinyApp(ui = ui, server = server)
