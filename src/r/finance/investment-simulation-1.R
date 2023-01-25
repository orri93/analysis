library(quantmod)
library(tidyverse)
library(lubridate)
library(xts)

# Parameters
year_count = 3
buy_per_year = 12

voo_buy_budget = 600
nov_buy_budget = 100
nasdx_buy_budget = 200

# Buy count
buy_count = year_count * buy_per_year

# Data Range
edate <- edate <- Sys.Date()
sdate <- edate - years(year_count)

# Get Data
voo_stock=getSymbols('voo',from=sdate,to=edate,auto.assign = F)
nov_stock=getSymbols('nov',from=sdate,to=edate,auto.assign = F)
nasdx_stock=getSymbols('nasdx',from=sdate,to=edate,auto.assign = F)

# Typically use previous value for NA
no.na <- which(is.na(voo_stock[,6]))      # no for NA
voo_stock[no.na,6] <- voo_stock[no.na-1,6]
no.na <- which(is.na(nov_stock[,6]))      # no for NA
nov_stock[no.na,6] <- nov_stock[no.na-1,6]
no.na <- which(is.na(nasdx_stock[,6]))
nasdx_stock[no.na,6] <- nasdx_stock[no.na-1,6]

# Only stock price
voo_price <- voo_stock[,6]
nov_price <- nov_stock[,6]
nasdx_price <- nasdx_stock[,6]

voo <- fortify.zoo(voo_price)
voo <- voo %>% mutate(date=Index, tag='VOO', value=VOO.Adjusted) %>% select(date, tag, value)
nov <- fortify.zoo(nov_price)
nov <- nov %>% mutate(date=Index, tag='NOV', value=NOV.Adjusted) %>% select(date, tag, value)
nasdx <- fortify.zoo(nasdx_price)
nasdx <- nasdx %>% mutate(date=Index, tag='NASDX', value=NASDX.Adjusted) %>% select(date, tag, value)

count <- nrow(voo)
stopifnot(count == nrow(nov))
stopifnot(count == nrow(nasdx))

buy_space <- count / buy_count

voo_last <- voo$value[nrow(voo)]
nov_last <- nov$value[nrow(nov)]
nasdx_last <- nasdx$value[nrow(nasdx)]

index <- 1
total_buy <- 0
buy <- data.frame(date=as.Date(character()), tag=character(), price=as.numeric(character()), shares=as.numeric(character()), sell=as.numeric(character()), profit=as.numeric(character()))
while(index < count) {
  by <- nrow(buy) + 1
  buy[by, 1] = voo$date[index]
  buy[by, 2] = voo$tag[index]
  buy[by, 3] = voo$value[index]
  buy[by, 4] = voo_buy_budget / voo$value[index]
  buy[by, 5] = voo_last * voo_buy_budget / voo$value[index]
  buy[by, 6] = (voo_last * voo_buy_budget / voo$value[index]) - voo_buy_budget
  total_buy <- total_buy + voo_buy_budget
  by <- nrow(buy) + 1
  buy[by, 1] = nov$date[index]
  buy[by, 2] = nov$tag[index]
  buy[by, 3] = nov$value[index]
  buy[by, 4] = nov_buy_budget / nov$value[index]
  buy[by, 5] = nov_last * nov_buy_budget / nov$value[index]
  buy[by, 6] = (nov_last * nov_buy_budget / nov$value[index]) - nov_buy_budget
  total_buy <- total_buy + nov_buy_budget
  by <- nrow(buy) + 1
  buy[by, 1] = nasdx$date[index]
  buy[by, 2] = nasdx$tag[index]
  buy[by, 3] = nasdx$value[index]
  buy[by, 4] = nasdx_buy_budget / nasdx$value[index]
  buy[by, 5] = nasdx_last * nasdx_buy_budget / nasdx$value[index]
  buy[by, 6] = (nasdx_last * nasdx_buy_budget / nasdx$value[index]) - nasdx_buy_budget
  total_buy <- total_buy + nasdx_buy_budget
  index <- index + buy_space
}

total_profit <- sum(buy$profit)
profit_ratio <- total_profit / total_buy
