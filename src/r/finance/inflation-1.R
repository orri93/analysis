# Dependencies
library(tidyverse)
library(lubridate)

# Import Data
rawvisitala <- read.table('tmp/finance/VIS01000.csv', sep=';', na.strings='.', skip=3, header=F)
rawap <- read.table('https://download.bls.gov/pub/time.series/ap/ap.data.0.Current', sep='\t', header=T, strip.white=T)
rawseries <- read.table('https://download.bls.gov/pub/time.series/ap/ap.series', sep='\t', comment.char='', header=T, strip.white=T)
rawarea <- read.table('https://download.bls.gov/pub/time.series/ap/ap.area', sep='\t', header=T, strip.white=T)

vt <- rawvisitala %>% mutate(Date = ymd(paste(gsub('M', '-', V1), '01', sep='-')))
hvt <- vt %>% mutate(Index = V2, Type = 'HVT', Monthly = as.numeric(V3), Yearly = as.numeric(V4))
hvt <- hvt %>% select(Date, Type, Index, Monthly, Yearly)
vtah <- vt %>% mutate(Index = V5, Type = 'VTAH', Monthly = as.numeric(V6), Yearly = as.numeric(V7))
vtah <- vtah %>% select(Date, Type, Index, Monthly, Yearly)
vt <- rbind(hvt, vtah)

houtxcode <- 'S37B'
houtxseries <- rawseries %>% filter(area_code == houtxcode & end_year == 2022)
houtxgasid <- 'APUS37B72620'
houtxgasap <- rawap %>% filter(series_id == houtxgasid)
houtxgasap <- houtxgasap %>% mutate(Date = ymd(paste(year, substr(period, 2, 3), '01', sep='-')), Value = as.numeric(value))

ggplot(data = vt, mapping = aes(x = Date, y = Index, color = Type)) + geom_line() + theme_light()
ggplot(data = vt, mapping = aes(x = Date, y = Monthly, color = Type)) + geom_line() + theme_light()
ggplot(data = vt, mapping = aes(x = Date, y = Yearly, color = Type)) + geom_line() + theme_light()

ggplot(data = houtxgasap, mapping = aes(x = Date, y = Value)) + geom_line() + theme_light()
