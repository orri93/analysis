# Dependencies
library(quantmod)
library(tidyverse)
library(lubridate)

# Import
raw <- read.csv('tmp/finance/investment.csv')

# Wrangling
investment <- raw %>%
  mutate(Date = as_datetime(Date)) %>%
  select(Date, Symbol, Shares, Price)

# Fetch Current Prices
price_table <- hashtab()
voo_quote <- getQuote('VOO')
qqq_quote <- getQuote('QQQ')
sethash(price_table, 'VOO', voo_quote$Last)
sethash(price_table, 'QQQ', qqq_quote$Last)

# Calculate
today <- as_datetime(Sys.Date())
holdings <- investment %>% mutate(Original = Price * Shares)
for (row in 1:nrow(holdings)) {
  holdings[row, 'Current'] = price_table[[holdings$Symbol[row]]]
}
holdings <- holdings %>% mutate(Value = Current * Shares)
holdings <- holdings %>% mutate(Profit = Value - Original)
holdings <- holdings %>% mutate(Ratio = Profit / Original, Elapsed = today - Date)
holdings <- holdings %>% mutate(Years = as.numeric(as.duration(Elapsed)) / 31536000)
holdings <- holdings %>% mutate(PPY = ifelse(Years > 1.0, Profit / Years, Profit))
holdings <- holdings %>% mutate(PPYR = PPY / Original)
total_buy <- sum(holdings$Original)
total_value <- sum(holdings$Value)
total_profit <- sum(holdings$Profit)
profit_ratio <- total_profit / total_buy
total_ppy <- sum(holdings$PPY)
ppyr <- total_ppy / total_buy
