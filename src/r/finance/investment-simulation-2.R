library(quantmod)
library(tidyverse)
library(lubridate)
library(checkr)
library(xts)

year_count <- 3
to <- Sys.Date()
investment_per_year <- 12

simulation <- data.frame(
  Symbol = c('VTI', 'VXUS', 'BND'),
  Shares = c(13, 3, 4))

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
  total_investment <- 0
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
      total_investment <- total_investment + original
    }
    index <- index + investment_interval
  }
  
  result <- simdf
  for (row in 1:nrow(simdf)) {
    symbol <- simdf$Symbol[row]
    symbinv <- investment %>% filter(Symbol == symbol)
    result[row,'Holding'] <- sum(symbinv$Shares)
    result[row,'Original'] <- sum(symbinv$Original)
    result[row,'Sell'] <- sum(symbinv$Sell)
    result[row,'Profit'] <- sum(symbinv$Profit)
  }
  result
}

result <- simulate(simulation, year_count, to, investment_per_year)
