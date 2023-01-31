# Dependencies
library(shiny)
library(quantmod)
library(tidyverse)
library(lubridate)
library(googlesheets4)

# Suspend any previous Google authorization
gs4_deauth()

# Import from Google Sheets
raw <- read_sheet('https://docs.google.com/spreadsheets/d/1pMQ1PUSKw4Fd7f21yGokdLx1EuQtn2KAGvaGyrjNU7Q')

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

# Format for output
holdings <- holdings %>% mutate(Date = format(Date))

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
  tableOutput('table'),
  tableOutput('result')
)

server <- function(input, output) {
  output$table <- renderTable({
    holdings
  })
  output$result <- renderTable({
    result
  })
}

shinyApp(ui, server)
