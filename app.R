#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

devtools::load_all()

update_edgelist()

graph <- build_graph()

the_choices <- graph %>% activate(nodes) %>% arrange(desc(centrality)) %>% pull(name)

# Define UI for application that draws a histogram
ui <- fluidPage(

  # Application title
  titlePanel("The Tangled Web Visualizer"),

  # Sidebar with a slider input for number of bins
  fluidPage(
    (
      selectInput("node_name",
                "Name of the Node (Ordered by Importance)",
                choices = the_choices)
    ),
      plotOutput("localWeb", height = "800px")
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  output$localWeb <- renderPlot({
    get_local_graph(graph, input$node_name)
  })
}

# Run the application
shinyApp(ui = ui, server = server)

