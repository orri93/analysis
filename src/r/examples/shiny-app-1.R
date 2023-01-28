library(shiny)

ui <- fluidPage(
  tags$h1("My basic Shiny app"),
  textInput(inputId = "txt", label = "What's your name?", placeholder = "e.g., John"),
  textOutput(outputId = "outName"))

server <- function(input, output, session) {
  output$outName <- renderText({paste0("Hello, ", input$txt)})
}

shinyApp(ui, server)
