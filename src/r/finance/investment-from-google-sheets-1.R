# Dependencies
library(quantmod)
library(tidyverse)
library(lubridate)
library(googlesheets4)

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
rm(symbol, quote)

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
rm(row)

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
rm(row, symbol, fh, infoline, type, fs)

# Plotting
ggplot(data = holdings, mapping = aes(x = Date, y = Investment, fill = Symbol)) + geom_bar(stat = "identity") + theme_light()
ggplot(data = holdings, mapping = aes(x = Date, y = Worth, fill = Symbol)) + geom_bar(stat = "identity") + theme_light()
ggplot(data = holdings, mapping = aes(x = Date, y = Profit, fill = Symbol)) + geom_bar(stat = "identity") + theme_light()
