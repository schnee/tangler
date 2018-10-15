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

# update_edgelist()

graph <- build_graph()

the_choices <-
  graph %>% activate(nodes) %>% arrange(desc(centrality)) %>% pull(name)

# Define UI for application that draws a histogram
ui <- fluidPage(titlePanel("The Tangled Web Visualizer"),
                # Sidebar with a slider input for number of bins
                sidebarLayout(
                  sidebarPanel(
                    checkboxInput("only_triangles", "Only Triangles"),
                    tags$div("Number of nodes: ",textOutput("count")),
                    tags$br(),
                    selectInput("node_name",
                                "Name of the Node (Ordered by Importance)",
                                # selected = the_choices[1],
                                choices = c("Choose One" = "",the_choices)),
                    tags$br(),
                    sliderInput("order",
                                "Order of Neighborhood",
                                min = 2, max = 5, value = 2,
                                step = 1),
                    tags$br(),
                    tags$div("This server is rather slow, so you will want to wait for
                             a bit longer than you think you need to")

                  ),
                  mainPanel(tabsetPanel(
                    type = "tabs",
                    tabPanel("Aesthetic", plotOutput("localWeb", height = "800px")),
                    tabPanel("Interactive", plotlyOutput("local_plotly", height = "800px")),
                    tabPanel(
                      "About",
                      tags$div(
                        "The Tangled Web Visualizer attempts to make sense of all the
                        connections and alleged connections in the Michael Cohen /
                        Donald Trump / Russia universe."
                      ),
                      tags$br(),
                      tags$div(
                        "The ",
                        strong("Name of the Node"),
                        " select box allows you to focus on the named
                        node, and the visualizer will show nodes within degree two of that node. Using the ",
                        strong("Only Triangles"),
                        " checkbox will limit the nodes to only those nodes that form
                        triangles in the overall graph, on the theory that nodes in triangles are important
                        for link prediction and community detection. Selecting triangles will reduce the number
                        of nodes and clean up the output. The ",
                        strong("Order of Neighborhood"), " slider defines how many 'hops' away from the selected",
                        "node to go to include within the graph."
                      ),
                      tags$br(),
                      tags$div(
                        "The ",
                        strong("Aesthetic"),
                        " tab shows a the network via an
                        attempt to make a pretty picture."
                      ),
                      tags$br(),
                      tags$div(
                        "The ",
                        strong("Interactive"),
                        " tab show a plot that one can enlarge / zoom
                        in/out and pan around. Additionally, the blue text on the edges are ",
                        strong("clickable"),
                        " and will open a browser window to the source of the
                        connection between the two nodes."
                      ),
                      tags$br(),
                      tags$div(
                        "All this is explained in the ",
                        tags$a(href = "https://schnee.github.io/tangled", "main site"),
                        " which also contains a solicitation for help, should you be so moved."
                      ),
                      tags$br(),
                      tags$div("Brent Schneeman, @schnee")
                      ),
                    tabPanel(
                      "The Whole Web",
                      tags$div("For more context, see ", tags$a(href="https://schnee.github.io/tangled", "the static site."),

                                                                "You will probably want to scroll around to see the image,
                                                                or right-click and open in a new tab."),
                      tags$img(src = "https://schnee.github.io/tangled/tangled.png")
                    )
                      ))
                  ))

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  local_graph <- reactive({
    node_name <- input$node_name
    only_tri <- input$only_triangles
    order <- input$order
    isolate(get_local_graph(graph, node_name, only_tri, order))
  })
  local_layout <- reactive({
    get_local_layout(local_graph())
  })

  the_new_choices <- reactive({
    if (input$only_triangles) {
      graph %>% activate(nodes) %>%
        filter(n_tri > 0) %>%
        arrange(desc(centrality)) %>% pull(name)
    }
    else {
      graph %>% activate(nodes) %>%
        arrange(desc(centrality)) %>% pull(name)
    }
  })

  observe({
    input$only_triangles
    isolate(updateSelectInput(session,
                      "node_name",
                      selected = input$node_name,
                      choices = c("Choose One" = "",the_new_choices())))
  })

  output$count <- renderText({
    length(the_new_choices())
  })

  output$localWeb <- renderPlot({
    if(nchar(input$node_name) > 0) {
    get_local_plot(local_graph(), local_layout(), input$node_name)
    }
  })

  output$local_plotly <- renderPlotly({
    if(nchar(input$node_name) > 0) {
    get_local_plotly(local_graph(), local_layout())
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
