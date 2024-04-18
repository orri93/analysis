# Investigate the IOT DHT dataset from 2020
#

# Dependencies
library(yaml)
library(tidyverse)
library(lubridate)
#library(RPostgres)
library(RPostgreSQL)
library(dygraphs)
library(xts)


# Read the secret configuration
secrets <- read_yaml("etc/iot/secrets.yml", readLines.warn=FALSE)


# Importing data from the database
driver = dbDriver("PostgreSQL")
connection = dbConnect(driver, host = secrets$database$host, port = secrets$database$port, user = secrets$database$user, password = secrets$database$password, dbname = secrets$database$name)

dhtraw <- dbGetQuery(connection, "SELECT ts, at, status, rh, t FROM dht")

dbd <- dbDisconnect(connection)
rm(secrets, driver, connection, dbd)


# Filter out rh and t
dht <- dhtraw %>% select(ts, rh, t)


# Convert to xts
dhtxts <- xts(dht[,-1], order.by = dht[,1])


dygraph(dhtxts) %>%
  dySeries("rh", drawPoints = TRUE, pointSize = 2, strokeWidth = 0) %>%
  dyRangeSelector(height = 20)
