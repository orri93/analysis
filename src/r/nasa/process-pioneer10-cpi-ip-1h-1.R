# Process NASA Pioneer 10 Charged Particle Instrument (CPI) data
# Detects cosmic rays in the Solar System See
# https://en.wikipedia.org/wiki/Pioneer_10
# https://spdf.gsfc.nasa.gov/pub/data/pioneer/pioneer10/particle/cpi/

# Dependencies
library(psych)
library(lubridate)
library(data.table) # For fread
library(tidyverse)
library(foreach)

#
# Downloading all 1 hour data and combine into one
#
path <- 'https://spdf.gsfc.nasa.gov/pub/data/pioneer/pioneer10/particle/cpi/ip_1hour_ascii/p10cp_hr'
yseq <- seq(1972, 1992)
rcpi <- data.frame()      # Empty data frame for result
foreach(y = yseq) %do% {
  url <- paste(path, as.character(y), '.asc', sep = '')
  ycpi <- fread(url)
  rcpi <- rbind(rcpi, ycpi)
}

# Convert date time
cpi <- rcpi %>% mutate(ts = date_decimal(V1) + days(V2) + hours(V3))

# Select and rename
cpi <- cpi %>% select(
  ts,
  RID2P   = V4,   # ID-2 rate for 11-20 MeV protons [cps]
  RID2HE  = V5,   # ID-2 rate for 11-20 MeV/nucleon helium [cps]
  RID3P   = V6,   # ID-3 rate for 20-24 MeV protons [cps]
  RID3HE  = V7,   # ID-3 rate for 20-24 MeV/nucleon helium [cps]
  RID4P   = V8,   # ID-4 rate for 24-29 MeV protons [cps]
  RID4HE  = V9,   # ID-4 rate for 24-29 MeV/nucleon helium [cps]
  RID5P   = V10,  # ID-5 rate for 29-67 MeV protons [cps]
  RID5HE  = V11,  # ID-5 rate for 29-67 MeV/nucleon helium [cps]
  RID5E1  = V12,  # ID-5 rate for 7-17 MeV electrons [cps]
  RID5E2  = V13,  # ID-5 rate for 2 x minimum-ionizing [cps]
  RID7    = V14,  # ID-7 + ID-13 integral rate for ions at E > 67 MeV/nucleon [cps]
  RID7ZG5 = V15)  # ID-7 integral rate for Z > 5 ions at E > 67 MeV/nucleon [cps]

# Replace fill in value with NA
cpi <- na_if(cpi, 1e31)

