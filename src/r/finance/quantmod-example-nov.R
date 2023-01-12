library(quantmod)
library(xts)
library(ggplot2)
# library(gridExtra) # grid.arrange
library(lubridate)

# graphics.on()

# Data Range
edate <- edate <- Sys.Date()
sdate <- edate - years(5)

# nov
nov_stock=getSymbols('nov',from=sdate,to=edate,auto.assign = F)

# Typically use previous value for NA
no.na <- which(is.na(nov_stock[,6]))      # no for NA
nov_stock[no.na,6] <- nov_stock[no.na-1,6]

# Only stock price
nov_price <- nov_stock[,6]

# log return using adjusted stock price
nov_rtn <- diff(log(nov_price),1)

# draw graph
ggplot(nov_price, aes(x = index(nov_price), y = nov_price)) +
  geom_line(color = "blue", size=1.2) + 
  ggtitle("NOV stock price") + xlab("Date") + ylab("Price(￦)") + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  scale_x_date(date_labels = "%y-%m", date_breaks = "3 months")

ggplot(nov_rtn, aes(x = index(nov_rtn), y = nov_rtn)) +
  geom_line(color = "red", size=1.2) + 
  ggtitle("NOV stock return") + xlab("Date") + ylab("Return(%)") + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  scale_x_date(date_labels = "%y-%m", date_breaks = "3 months")
