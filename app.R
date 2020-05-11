require(shiny)
require(visNetwork)
require(rio)
require(colorfindr)
require(dplyr)
require(shinyWidgets)

#rsconnect::setAccountInfo(name='tourthroughart', token='0F47D82102AEDF1597538A2A27FD3A0A', secret='3d0bD6XHqFyS5XCXLPiVWb8flGWF3BjpijSpaM9t')



ui <- bootstrapPage(
  tags$head(
    tags$meta(charset="UTF-8"),
    tags$meta(name="viewport", content="width=device-width, initial-scale=1"),
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    tags$link(href="https://fonts.googleapis.com/css2?family=Comfortaa:wght@600&display=swap", rel="stylesheet"),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  
  tags$body(width="100%", height="100%",
            navbarPage("Tour Through Modern Art",
                       tabPanel("History", 
                                source("www/timeline.r", local = TRUE)$value
                       ),
                       tabPanel("Reactions",
                                tags$p(class = "reactions-connections", "we can see who influenced", tags$br(), "who"),
                                visNetworkOutput("network", width = "40.89vw", height = "64.81vh")
                       ),
                       tabPanel("Palettes", 
                                sidebarPanel(
                                  pickerGroupUI(
                                    id = "my-filters",
                                    inline = FALSE,
                                    params = list(
                                      Style = list(inputId = "Style", title = "Select Style", placeholder = 'Select'),
                                      Artist = list(inputId = "Artist", title = "Select Artist", placeholder = 'Select'),
                                      Painting = list(inputId = "Painting", title = "Select Painting", placeholder = 'Select')
                                )),
                                plotOutput("palette", width = "23vw", height = "27vh"),
                                htmlOutput("img", width = "23vw", height = "27vh")
                       )
            ) 
            
  )
))

server <- function(input, output, session) {

  #############data sets#############  
  nodesdata <- rio::import("www/nodesdata.csv")
  edgesdata <- rio::import("www/edgesdata.csv")
  artdata <- rio::import("www/art.csv")
  
  #############Second Tab#############
  output$network <- renderVisNetwork({
    nodes <- data.frame(id = 1:33, 
                        shape = "circularImage",
                        image = nodesdata$Image,
                        label = nodesdata$Label)
    
    edges <- data.frame(from = edgesdata$From, to = edgesdata$To)
    
    visNetwork(nodes, edges) %>% 
      visNodes(shapeProperties = list(useBorderWithImage = TRUE)) %>%
      visLayout(randomSeed = 2)
  })
  
  #############Third Tab#############
  
  res_mod <- callModule(
    module = pickerGroupServer,
    id = "my-filters",
    data = artdata,
    vars = c("Style", "Artist", "Painting")
  )

  
  output$palette <- renderPlot({
    get_colors(res_mod()$URL) %>% 
      make_palette(n = 5)
  })
  
  output$img <- renderUI({
    tags$img(src = res_mod()$URL)
  })

}

shinyApp(ui, server)
