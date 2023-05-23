# Dependencies
library(shiny)
library(quantmod)
library(tidyverse)
library(lubridate)
library(googlesheets4)
library(DT)

# Suspend any previous Google authorization
gs4_deauth()

# Import from Google Sheets
raw <- read_sheet('https://docs.google.com/spreadsheets/d/1pMQ1PUSKw4Fd7f21yGokdLx1EuQtn2KAGvaGyrjNU7Q')
info <- read_sheet('https://docs.google.com/spreadsheets/d/1pMQ1PUSKw4Fd7f21yGokdLx1EuQtn2KAGvaGyrjNU7Q', range="Information")

# Wrangling
investment <- raw %>%
  mutate(Date = as_datetime(Date)) %>%
  select(Date, Symbol, Shares, Price)

# Fetch Current Prices
price_table <- hashtab()
for (row in 1:nrow(investment)) {
  symbol <- investment$Symbol[row]
  quote <- getQuote(symbol)
  sethash(price_table, symbol, quote$Last)
}

# Calculate
today <- as_datetime(Sys.Date())
holdings <- investment %>% mutate(Investment = Price * Shares)
for (row in 1:nrow(holdings)) {
  holdings[row, 'Last'] = price_table[[holdings$Symbol[row]]]
}
holdings <- holdings %>% mutate(Worth = Last * Shares)
holdings <- holdings %>% mutate(Profit = Worth - Investment)
holdings <- holdings %>% mutate(Ratio = Profit / Investment, Elapsed = today - Date)
holdings <- holdings %>% mutate(Years = as.numeric(as.duration(Elapsed)) / 31536000)
holdings <- holdings %>% mutate(PPY = ifelse(Years > 1.0, Profit / Years, Profit))
holdings <- holdings %>% mutate(PPYR = PPY / Investment)
total_inv <- sum(holdings$Investment)
total_worth <- sum(holdings$Worth)
total_profit <- sum(holdings$Profit)
profit_ratio <- total_profit / total_inv
total_ppy <- sum(holdings$PPY)
ppyr <- total_ppy / total_inv
holdings <- holdings %>% mutate(IR = Investment / total_inv, WR = Worth / total_worth)

# Summarize
summary <- data.frame(Symbol=character())
maphash(price_table, function(k, v) {
  n <- nrow(summary) + 1
  summary[n, 1] <<- k
})
type_table <- hashtab()
for (row in 1:nrow(summary)) {
  symbol <- summary$Symbol[row]
  fh <- holdings %>% filter(Symbol == symbol)
  infoline <- filter(info, Symbol == symbol)
  type <- infoline$Type
  sethash(type_table, type, infoline)
  summary$Name[row] <- infoline$Name
  summary$Type[row] <- type
  summary$Shares[row] <- sum(fh$Shares)
  summary$Investment[row] <- sum(fh$Investment)
  summary$Last[row] <- price_table[[symbol]]
  summary$Worth[row] <- sum(fh$Worth)
  summary$Profit[row] <- sum(fh$Profit)
}
summary <- summary %>% mutate(Ratio = Profit / Investment, IR = Investment / total_inv, WR = Worth / total_worth)
summary <- arrange(summary, Symbol) # Order
types <- data.frame(Type=character())
maphash(type_table, function(k, v) {
  n <- nrow(types) + 1
  types[n, 1] <<- k
})
for (row in 1:nrow(types)) {
  type <- types$Type[row]
  fs <- summary %>% filter(Type == type)
  types$Investment[row] <- sum(fs$Investment)
  types$Worth[row] <- sum(fs$Worth)
  types$Profit[row] <- sum(fs$Profit)
}
types <- types %>% mutate(Ratio = Profit / Investment, IR = Investment / total_inv, WR = Worth / total_worth)
types <- arrange(types, Type) # Order

# Format for output
holdings <- holdings %>% mutate(Date = format(Date))

eps <- 1E-5

result <- data.frame(
  Result = c(
    "Total Investment",
    "Total Worth",
    "Total Profit",
    "Profit Ratio"),
  Value = c(
    total_inv,
    total_worth,
    total_profit,
    profit_ratio * 100.0),
  Unit = c(
    "USD",
    "USD",
    "USD",
    "%"))

ui <- fluidPage(
  tags$h1("Investments"),
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
