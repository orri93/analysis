library(shiny)
library(quantmod)
library(lubridate)
library(tidyverse)
library(crudtable)
library(checkr)
library(xts)

default_year_count <- 3
default_ipy <- 12

simulation <- data.frame(
  Symbol = c('VTI', 'VXUS', 'BND'),
  Shares = c(6, 1, 2))

# Data Access Object from the simulation data frame
dao <- dataFrameDao(simulation)

simulate <- function(simdf, year_count, until, ipy) {
  investment_count <- year_count * ipy
  from <- until - years(year_count)
  
  count <- chk_max_int()
  history_table <- hashtab()
  for (row in 1:nrow(simdf)) {
    symbol <- simdf$Symbol[row]
    
    # Get Stock History
    stockhistory = getSymbols(symbol, from=from, to=until, auto.assign=F)
    
    # Only stock price
    stockprices <- stockhistory[,6]
    
    # Typically use previous value for NA
    no.na <- which(is.na(stockprices[,1])) # no for NA
    stockprices[no.na,1] <- stockprices[no.na-1,1]
    
    # Convert to Data Frame
    pricehistory <- fortify.zoo(stockprices)
    pricehistory <- pricehistory %>% mutate(Date=Index)
    pricehistory[,'Price'] = pricehistory[,2]
    pricehistory <- pricehistory %>% select(Date, Price)
    
    sethash(history_table, symbol, pricehistory)
    if (nrow(pricehistory) < count) {
      count <- nrow(pricehistory)
    }
  }
  investment_interval <- round(count / investment_count)
  
  index <- 1
  investment <- data.frame(Date=as.Date(character()), Symbol=character(), Price=as.numeric(character()), Shares=as.numeric(character()), Original=as.numeric(character()), Sell=as.numeric(character()), Profit=as.numeric(character()))
  while(index < count) {
    for (row in 1:nrow(simdf)) {
      n  <- nrow(investment) + 1
      symbol <- simdf$Symbol[row]
      history <- history_table[[symbol]]
      last <- history$Price[nrow(history)]
      price <- history$Price[index]
      shares <- simdf$Shares[row]
      original <- price * shares
      sell <- last * shares
      profit <- sell - original
      investment[n, 1] = history$Date[index]
      investment[n, 2] = symbol
      investment[n, 3] = price
      investment[n, 4] = shares
      investment[n, 5] = original
      investment[n, 6] = sell
      investment[n, 7] = profit
    }
    index <- index + investment_interval
  }
  
  result <- simdf
  for (row in 1:nrow(simdf)) {
    symbol <- simdf$Symbol[row]
    symbinv <- investment %>% filter(Symbol == symbol)
    inv <- sum(symbinv$Original)
    profit <- sum(symbinv$Profit)
    prrat <- profit / inv
    ipy <- inv / year_count
    ppy <- profit / year_count
    ppyr <- ppy / inv
    result[row,'Holding'] <- sum(symbinv$Shares)
    result[row,'Investment'] <- inv
    result[row,'Sell'] <- sum(symbinv$Sell)
    result[row,'Profit'] <- profit
    result[row,'Ratio'] <- prrat
    result[row,'IPY'] <- ipy
    result[row,'PPY'] <- ppy
    result[row,'PPYR'] <- ppyr
  }
  
  # Create the Summary Row
  total_inv <- sum(result$Investment)
  total_shares <- sum(result$Shares)
  total_holding <- sum(result$Holding)
  total_value <- sum(result$Sell)
  total_profit <- sum(result$Profit)
  tpr <- total_profit / total_inv
  total_ipy <- total_inv / year_count
  total_ppy <- total_profit / year_count
  total_ppyr <- total_ppy / total_inv
  n  <- nrow(result) + 1
  result[n, 1] = "Total"
  result[n, 2] = total_shares
  result[n, 3] = total_holding
  result[n, 4] = total_inv
  result[n, 5] = total_value
  result[n, 6] = total_profit
  result[n, 7] = tpr
  result[n, 8] = total_ipy
  result[n, 9] = total_ppy
  result[n, 10] = total_ppyr
  
  result
}

ui <- fluidPage(
  tags$h1("Investment Simulator"),
  textInput(inputId="yearcount", label="Year Count", placeholder=toString(default_year_count)),
  textInput(inputId="until", label="End Date", placeholder=Sys.Date()),
  textInput(inputId="ipy", label="Investments per Year", placeholder=toString(default_ipy)),
  crudTableUI('crud'),
  tags$h2("Investment Results"),
  tableOutput('table')
)

server <- function(input, output) {
  crudTableServer('crud', dao)
  
  output$table <- renderTable({
    data <- dao$getData()
    validate(
      need(nrow(data) > 0, "Simulation Table can't be empty")
    )
    simin <- data %>% select(Symbol, Shares)
    until <- as.Date(input$until, optional = TRUE)
    if (is.na(until)) {
      until <- Sys.Date()
    }
    yearcount <- as.numeric(input$yearcount)
    if (is.na(yearcount)) {
      yearcount = default_year_count
    }
    ipy <- as.numeric(input$ipy)
    if (is.na(ipy)) {
      ipy = default_ipy
    }
    simulate(simin, yearcount, until, ipy)
  })
}

shinyApp(ui, server)
