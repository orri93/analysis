# Dependencies
library(shiny)
library(reshape2)
library(tidyverse)
library(lubridate)
library(googlesheets4)
library(DT)

# Suspend any previous Google authorization
gs4_deauth()

# Import from Google Sheets
raw <- read_sheet('https://docs.google.com/spreadsheets/d/17H0TUFm_DT7yErU6PDZMEvs_1enOrKr4QIPy5FRhNdk')

# Wrangling
cost <- raw %>% mutate(Date = ymd(Year * 10000 + Month * 100 + 01))
costmelt <- melt(cost, id = c('Year','Month','Date'), na.rm = TRUE)
costenergy <- costmelt %>% filter(variable %in% c('Electricity', 'Gas')) %>%
  select(Date, Price = value, Energy = variable)
costcommun <- costmelt %>% filter(variable %in% c('Mobile', 'Internet')) %>%
  select(Date, Price = value, Communication = variable)

# Aggregate
aggregate(cost, list(cost$Year), FUN=mean)

ui <- fluidPage(
  tags$h1("Costs"),
  DTOutput('table'),
  tags$h2("Summary"),
  DTOutput('summary'),
  tags$h2("Type Summary"),
  DTOutput('typesummary'),
  tags$h2("Result"),
  tableOutput('result'),
  tags$h2("Visualization"),
  tags$h3("Holdings"),
  plotOutput("plotinv"),
  plotOutput("plotworth"),
  plotOutput("plotprofit"),
  tags$h3("Summary"),
  plotOutput("plotsumprofit"),
  plotOutput("plotsumratio"),
  plotOutput("plottypessumprofit"),
  plotOutput("plottypessumratio"),
  tags$h3("Investment"),
  plotOutput("plotpieinv"),
  tags$h3("Worth"),
  plotOutput("plotpieworth"),
  tags$h3("Types Investment"),
  plotOutput("plottypespieinv"),
  tags$h3("Types Worth"),
  plotOutput("plottypespieworth")
)

server <- function(input, output) {
  output$table <- renderDT({
    datatable(holdings) %>% formatCurrency(c('Price', 'Investment', 'Last', 'Worth', 'Profit', 'PPY')) %>% formatPercentage(c('Ratio', 'PPYR', 'IR', 'WR'), 2) %>% formatRound('Years', 3) %>% formatStyle(columns=1:15, color = styleInterval(cuts=c(-eps, eps), values=c("red", "black", "green")))
  })
  output$summary <- renderDT({
    datatable(summary, options=list(iDisplayLength=15)) %>% formatCurrency(c('Investment', 'Last', 'Worth', 'Profit')) %>% formatPercentage(c('Ratio', 'IR', 'WR'), 2) %>% formatStyle(columns=1:11, color = styleInterval(cuts=c(-eps, eps), values=c("red", "black", "green")))
  })
  output$typesummary <- renderDT({
    datatable(types) %>% formatCurrency(c('Investment', 'Worth', 'Profit')) %>% formatPercentage(c('Ratio', 'IR', 'WR'), 2) %>% formatStyle(columns=1:7, color = styleInterval(cuts=c(-eps, eps), values=c("red", "black", "green")))
  })
  output$result <- renderTable({
    result
  })
  output$plotinv <- renderPlot({
    ggplot(data = holdings, mapping = aes(x = Date, y = Investment, fill = Symbol)) +
      geom_bar(stat = "identity") + ggtitle("Holding Investment") + scale_y_continuous(label=scales::dollar_format()) + theme_light()
  })
  output$plotworth <- renderPlot({
    ggplot(data = holdings, mapping = aes(x = Date, y = Worth, fill = Symbol)) +
      geom_bar(stat = "identity") + ggtitle("Holding Worth") + scale_y_continuous(label=scales::dollar_format()) + theme_light()
  })
  output$plotprofit <- renderPlot({
    ggplot(data = holdings, mapping = aes(x = Date, y = Profit, fill = Symbol)) +
      geom_bar(stat = "identity") + ggtitle("Holding Profit") + scale_y_continuous(label=scales::dollar_format()) + theme_light()
  })
  output$plotsumprofit <- renderPlot({
    ggplot(data = summary, mapping = aes(x = Symbol, y = Profit)) +
      geom_bar(stat='identity') + ggtitle("Summary Profit") + scale_y_continuous(label=scales::dollar_format()) + theme_light()
  })
  output$plotsumratio <- renderPlot({
    ggplot(data = summary, mapping = aes(x = Symbol, y = Ratio)) +
      geom_bar(stat='identity') + ggtitle("Summary Profit Ratio") + scale_y_continuous(label=scales::percent_format(accuracy=0.1)) + theme_light()
  })
  output$plottypessumprofit <- renderPlot({
    ggplot(data = types, mapping = aes(x = Type, y = Profit)) +
      geom_bar(stat='identity') + ggtitle("Types Summary Profit") + scale_y_continuous(label=scales::dollar_format()) + theme_light()
  })
  output$plottypessumratio <- renderPlot({
    ggplot(data = types, mapping = aes(x = Type, y = Ratio)) +
      geom_bar(stat='identity') + ggtitle("Summary Profit Ratio") + scale_y_continuous(label=scales::percent_format(accuracy=0.1)) + theme_light()
  })
  output$plotpieinv <- renderPlot({
    pie(summary$Investment, summary$Symbol)
  })
  output$plotpieworth <- renderPlot({
    pie(summary$Worth, summary$Symbol)
  })
  output$plottypespieinv <- renderPlot({
    pie(types$Investment, types$Type)
  })
  output$plottypespieworth <- renderPlot({
    pie(types$Worth, types$Type)
  })
}

shinyApp(ui, server)
