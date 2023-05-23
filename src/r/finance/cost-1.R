# Dependencies
library(tidyverse)
library(lubridate)
library(googlesheets4)
library(reshape2)

# Suspend any previous Google authorization
gs4_deauth()

# Import from Google Sheets
raw <- read_sheet('https://docs.google.com/spreadsheets/d/17H0TUFm_DT7yErU6PDZMEvs_1enOrKr4QIPy5FRhNdk')

# Wrangling
cost <- raw %>% mutate(Date = ymd(Year * 10000 + Month * 100 + 01))
costmelt <- melt(cost, id = c('Year','Month','Date'), na.rm = TRUE)
costenergy <- costmelt %>% filter(variable %in% c('Electricity', 'Gas')) %>%
  select(Date, Price = value, Energy = variable)
costcommun <- costmelt %>% filter(variable %in% c('Mobile', 'Internet')) %>%
  select(Date, Price = value, Communication = variable)

# Aggregate
aggregate(cost, list(cost$Year), FUN=mean)

# Plotting
ggplot(data = costenergy, mapping = aes(x = Date, y = Price, fill = Energy)) +
  geom_area(stat = "identity") + ggtitle("Energy Cost") + scale_y_continuous(label=scales::dollar_format()) + theme_light()
ggplot(data = costcommun, mapping = aes(x = Date, y = Price, fill = Communication)) +
  geom_area(stat = "identity") + ggtitle("Communication Cost") + scale_y_continuous(label=scales::dollar_format()) + theme_light()
