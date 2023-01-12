#=========================================================================#
# Financial Econometrics & Derivatives, ML/DL using R, Python, Tensorflow  
# by Sang-Heon Lee 
#————————————————————————-#
# Retreiving Stock Price using quantmod
#=========================================================================#
library(quantmod)
library(xts)
library(ggplot2)
library(gridExtra) # grid.arrange

graphics.off()
rm(list=ls())

# Data Range
sdate <- as.Date("2018-07-01")
edate <- as.Date("2019-12-31")

# Samsung Electronics (005930), Naver (035420)
ss_stock=getSymbols('005930.KS',from=sdate,to=edate,auto.assign = F)
nv_stock=getSymbols('035420.KS',from=sdate,to=edate,auto.assign = F)

# Typically use previous value for NA
no.na <- which(is.na(ss_stock[,6]))      # no for NA
ss_stock[no.na,6] <- ss_stock[no.na-1,6]

no.na <- which(is.na(nv_stock[,6]))
nv_stock[no.na,6] <- nv_stock[no.na-1,6] 

# Only stock price
ss_price <- ss_stock[,6]
nv_price <- nv_stock[,6]

# log return using adjusted stock price
ss_rtn <- diff(log(ss_price),1)
nv_rtn <- diff(log(nv_price),1)

# draw graph
x11(width=5.5, height=6)
plot1<-ggplot(ss_price, aes(x = index(ss_price), y = ss_price)) +
  geom_line(color = "blue", size=1.2) + 
  ggtitle("SEC stock price") + xlab("Date") + ylab("Price(￦)") + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  scale_x_date(date_labels = "%y-%m", date_breaks = "3 months")

plot2 <- ggplot(ss_rtn, aes(x = index(ss_rtn), y = ss_rtn)) +
  geom_line(color = "red", size=1.2) + 
  ggtitle("SEC stock return") + xlab("Date") + ylab("Return(%)") + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  scale_x_date(date_labels = "%y-%m", date_breaks = "3 months")

grid.arrange(plot1, plot2, ncol=1, nrow = 2)

x11(width=5.5, height=6)
plot1<-ggplot(nv_price, aes(x = index(nv_price), y = nv_price)) +
  geom_line(color = "blue", size=1.2) + 
  ggtitle("Naver stock price") + xlab("Date") + ylab("Price(￦)") + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  scale_x_date(date_labels = "%y-%m", date_breaks = "3 months")

plot2 <- ggplot(nv_rtn, aes(x = index(nv_rtn), y = nv_rtn)) +
  geom_line(color = "red", size=1.2) + 
  ggtitle("Naver stock return") + xlab("Date") + ylab("Return(%)") + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  scale_x_date(date_labels = "%y-%m", date_breaks = "3 months")

grid.arrange(plot1, plot2, ncol=1, nrow = 2)
