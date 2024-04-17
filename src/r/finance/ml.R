# Investigate ML imported data
#

library(yaml)
library(tidyverse)
library(lubridate)
library(RPostgreSQL)
library(jsonlite)
library(httr)


# Read the secret configuration
secrets <- read_yaml("etc/finance/secrets.yml", readLines.warn=FALSE)

avgq <- function(symbol) {
  avapikey <- paste("apikey", secrets$alphavantage$api_key, sep = "=")
  avsymbol <- paste("symbol", symbol, sep = "=")
  avparam <- paste("function=GLOBAL_QUOTE", avsymbol, avapikey, sep = "&")
  avquery <- paste(secrets$alphavantage$url, avparam, sep = "?")
  avresponse <- GET(url = avquery)
  avrretcode <- status_code(avresponse)
  if (avrretcode == 200) {
    avrrettext <- content(avresponse, "text", encoding = "UTF-8")
    avrvalues <- fromJSON(avrrettext, flatten = FALSE)
    return (avrvalues$`Global Quote`$`05. price`)
  }
}

# Importing data from the database
driver = dbDriver("PostgreSQL")
connection = dbConnect(driver, host = secrets$database$host, port = secrets$database$port, user = secrets$database$user, password = secrets$database$password, dbname = secrets$database$name)

purraw <- dbGetQuery(connection, "SELECT trade_date, settlement_date, symbol, quantity, price FROM ml WHERE action = 'Purchase'")
divraw <- dbGetQuery(connection, "SELECT trade_date, settlement_date, symbol, amount FROM ml WHERE action = 'Dividend'")

bndpurraw <- dbGetQuery(connection, "SELECT trade_date, settlement_date, quantity, price FROM ml WHERE symbol = 'BND' AND action = 'Purchase'")
bnddivraw <- dbGetQuery(connection, "SELECT trade_date, settlement_date, symbol, amount FROM ml WHERE action = 'Dividend'")

dbDisconnect(connection)
rm(driver, connection)


# Query Alpha Vantage
avapikey <- paste("apikey", secrets$alphavantage$api_key, sep = "=")
avparam <- paste("function=MARKET_STATUS", avapikey, sep = "&")
avquery <- paste(secrets$alphavantage$url, avparam, sep = "?")
avresponse <- GET(url = avquery)
avrretcode <- status_code(avresponse)
avrrettext <- content(avresponse, "text", encoding = "UTF-8")
avr <- fromJSON(avrrettext, flatten = FALSE)
avrmarkets <- avr$markets
avrusa <- filter(avrmarkets, region == 'United States')
usamarketstatus <- avrusa$current_status

symbol <- 'IBM'
avapikey <- paste("apikey", secrets$alphavantage$api_key, sep = "=")
avsymbol <- paste("symbol", symbol, sep = "=")
avparam <- paste("function=GLOBAL_QUOTE", avsymbol, avapikey, sep = "&")
avquery <- paste(secrets$alphavantage$url, avparam, sep = "?")
avresponse <- GET(url = avquery)
avrretcode <- status_code(avresponse)
avrrettext <- content(avresponse, "text", encoding = "UTF-8")
avr <- fromJSON(avrrettext, flatten = FALSE)


