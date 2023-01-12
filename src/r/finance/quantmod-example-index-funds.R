library(quantmod)
library(xts)
library(ggplot2)
library(lubridate)

# Data Range
edate <- edate <- Sys.Date()
sdate <- edate - years(5)

# Get Data
voo_stock=getSymbols('voo',from=sdate,to=edate,auto.assign = F)
ivv_stock=getSymbols('ivv',from=sdate,to=edate,auto.assign = F)
spy_stock=getSymbols('spy',from=sdate,to=edate,auto.assign = F)
nasdx_stock=getSymbols('nasdx',from=sdate,to=edate,auto.assign = F)

# Typically use previous value for NA
no.na <- which(is.na(voo_stock[,6]))      # no for NA
voo_stock[no.na,6] <- voo_stock[no.na-1,6]
no.na <- which(is.na(ivv_stock[,6]))
ivv_stock[no.na,6] <- ivv_stock[no.na-1,6]
no.na <- which(is.na(spy_stock[,6]))
spy_stock[no.na,6] <- spy_stock[no.na-1,6]
no.na <- which(is.na(nasdx_stock[,6]))
nasdx_stock[no.na,6] <- nasdx_stock[no.na-1,6]

# Only stock price
voo_price <- voo_stock[,6]
ivv_price <- ivv_stock[,6]
spy_price <- spy_stock[,6]
nasdx_price <- nasdx_stock[,6]

# draw graph
ggplot(voo_price, aes(x = index(voo_price), y = voo_price)) +
  geom_line(color = "blue", size=1.2) + 
  ggtitle("Vanguard S&P 500 EFT price") + xlab("Date") + ylab("Price") + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  scale_x_date(date_labels = "%y-%m", date_breaks = "3 months")

ggplot(ivv_price, aes(x = index(ivv_price), y = ivv_price)) +
  geom_line(color = "blue", size=1.2) + 
  ggtitle("iShares Core S&P 500 EFT price") + xlab("Date") + ylab("Price") + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  scale_x_date(date_labels = "%y-%m", date_breaks = "3 months")

ggplot(spy_price, aes(x = index(spy_price), y = spy_price)) +
  geom_line(color = "blue", size=1.2) + 
  ggtitle("SPDR S&P 500 EFT Trust price") + xlab("Date") + ylab("Price") + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  scale_x_date(date_labels = "%y-%m", date_breaks = "3 months")

ggplot(nasdx_price, aes(x = index(nasdx_price), y = nasdx_price)) +
  geom_line(color = "blue", size=1.2) + 
  ggtitle("Shelton NASDAQ-100 Index Direct price") + xlab("Date") + ylab("Price") + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  scale_x_date(date_labels = "%y-%m", date_breaks = "3 months")
