# Dependencies
library(quantmod)
library(tidyverse)
library(lubridate)

# Fetch Current Prices
price_table <- hashtab()
voo_quote <- getQuote('VOO')
vti_quote <- getQuote('VTI')
vxus_quote <- getQuote('VXUS')
bnd_quote <- getQuote('BND')
qqq_quote <- getQuote('QQQ')
amzn_quote <- getQuote('AMZN')
goog_quote <- getQuote('GOOG')
sethash(price_table, 'VOO', voo_quote$Last)
sethash(price_table, 'QQQ', qqq_quote$Last)
sethash(price_table, 'AMZN', amzn_quote$Last)
sethash(price_table, 'GOOG', goog_quote$Last)