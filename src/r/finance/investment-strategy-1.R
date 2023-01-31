# Dependencies
library(quantmod)
library(tidyverse)
library(lubridate)

amount <- 2400
invstrinp <- data.frame(
  Symbol = c("VOO", "VTI", "VXUS", "BND", "QQQ"),
  Ratio = c(0.22, 0.22, 0.16, 0.2, 0.2))

ratio_sum_check = sum(invstrinp$Ratio)

invstr <- invstrinp %>% mutate(Amount = amount * Ratio)
# Fetch Current Prices
for (row in 1:nrow(invstr)) {
  quote <- getQuote(invstr$Symbol[row])
  invstr[row, 'Last'] = quote$Last
}
rm(row, quote)
invstr <- invstr %>% mutate(Stock = floor(Amount / Last))
invstr <- invstr %>% mutate(Spend = Stock * Last)
total_spend <- sum(invstr$Spend)
spend_diff <- amount - total_spend
invstr <- invstr %>% mutate(SR = round(Spend / total_spend, 2))
