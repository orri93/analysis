# Process NASA Voyager Cosmic Ray Subsystem (CRS)
#

# Dependencies
# library(zoo)
library(tidyverse)
library(lubridate)
library(data.table)

# Function for aggregation
aggnrmean <- function(df, n = 5, FUN = mean) {
  aggregate(df,
            by = list(gl(ceiling(nrow(df)/n), n)[1:nrow(df)]),
            FUN = FUN)[-1]
}

# Download Data

# Download Trajectory data
# Format information see 
# https://spdf.gsfc.nasa.gov/pub/data/voyager/voyager1/traj/ssc/vy1trj_ssc_fmt.txt
rtrajv1 <- fread("https://spdf.gsfc.nasa.gov/pub/data/voyager/voyager1/traj/ssc/vy1trj_ssc_1d.asc")
rtrajv2 <- fread("https://spdf.gsfc.nasa.gov/pub/data/voyager/voyager2/traj/ssc/vy2trj_ssc_1d.asc")

# Download HET-I Coincidence Rates A-Stopping H and He
# See https://voyager.gsfc.nasa.gov/data.html
rasthhev1 <- fread("https://voyager.gsfc.nasa.gov/crs/lists/v1/p_1788e9c83f7.txt")
rasthhev2 <- fread("https://voyager.gsfc.nasa.gov/crs/lists/v2/p_1788e9c83f7.txt")

# Convert date time
trajv1 <- rtrajv1 %>% mutate(tv1ts = date_decimal(V1) + days(V2))
trajv2 <- rtrajv2 %>% mutate(tv2ts = date_decimal(V1) + days(V2))
asthhev1 <- rasthhev1 %>% mutate(v1ts = as_datetime(V1))
asthhev2 <- rasthhev2 %>% mutate(v2ts = as_datetime(V1))

# Select and rename
trajv1 <- trajv1 %>% select(tv1ts, v1hradau = V3, v1seclat = V4, v1seclon = V5, v1hellat = V6, v1hellon = V7, v1hillon = V8)
trajv2 <- trajv2 %>% select(tv2ts, v2hradau = V3, v2seclat = V4, v2seclon = V5, v2hellat = V6, v2hellon = V7, v2hillon = V8)
asthhev1 <- asthhev1 %>% select(v1ts, v1v2 = V2, v1v3 = V3)
asthhev2 <- asthhev2 %>% select(v2ts, v2v2 = V2, v2v3 = V3)

# Date Range
trajv1mints <- min(trajv1$tv1ts)
trajv2mints <- min(trajv2$tv2ts)
trajv1maxts <- max(trajv1$tv1ts)
trajv2maxts <- max(trajv2$tv2ts)
asthhev1mints <- min(asthhev1$v1ts)
asthhev2mints <- min(asthhev2$v2ts)
asthhev1maxts <- max(asthhev1$v1ts)
asthhev2maxts <- max(asthhev2$v2ts)
mints <- max(trajv1mints, trajv2mints, asthhev1mints, asthhev2mints)
maxts <- min(trajv1maxts, trajv2maxts, asthhev1maxts, asthhev2maxts)

# Filter data
trajv1 <- trajv1 %>% filter(tv1ts >= mints & tv1ts <= maxts)
trajv2 <- trajv2 %>% filter(tv2ts >= mints & tv2ts <= maxts)
asthhev1 <- asthhev1 %>% filter(v1ts >= mints & v1ts <= maxts)
asthhev2 <- asthhev2 %>% filter(v2ts >= mints & v2ts <= maxts)

# Aggregate by Mean
asthhev1 <- aggnrmean(asthhev1, 40)
asthhev2 <- aggnrmean(asthhev2, 40)

# Convert to data tables
setDT(trajv1)
setDT(trajv2)
setDT(asthhev1)
setDT(asthhev2)


# Combine Voyager 1 and 2 Trajectory data into one set
#
setkey(trajv1, tv1ts)
setkey(trajv2, tv2ts)
traj <- trajv1[trajv2, roll = "nearest"]

ggplot(data = traj) +
  geom_line(aes(x = tv1ts, y = v1hradau), color = 'blue') +
  geom_line(aes(x = tv1ts, y = v2hradau), color = 'green')

ggplot(data = traj) +
  geom_line(aes(x = tv1ts, y = v1seclat), color = 'blue') +
  geom_line(aes(x = tv1ts, y = v2seclat), color = 'green')

ggplot(data = traj) +
  geom_line(aes(x = tv1ts, y = v1seclon), color = 'blue') +
  geom_line(aes(x = tv1ts, y = v2seclon), color = 'green')

ggplot(data = traj) +
  geom_line(aes(x = tv1ts, y = v1hellat), color = 'blue') +
  geom_line(aes(x = tv1ts, y = v2hellat), color = 'green')


# Combine Voyager 1 and 2 data into one set
#
setkey(asthhev1, v1ts)
setkey(asthhev2, v2ts)

asthhe <- asthhev2[ asthhev1, roll = "nearest" ]

ggplot(data = asthhe) +
  geom_line(aes(x = v2ts, y = v1v2), color = 'blue') +
  geom_line(aes(x = v2ts, y = v2v2), color = 'green') +
  scale_y_continuous(trans = 'log10')

ggplot(data = asthhe) +
  geom_line(aes(x = v2ts, y = v1v3), color = 'blue') +
  geom_line(aes(x = v2ts, y = v2v3), color = 'green')


# Combine Trajectory and Cosmic Ray data into one set for each Voyager
#
trasthhev1 <- trajv1[ asthhev1, roll = "nearest" ]
trasthhev2 <- trajv2[ asthhev2, roll = "nearest" ]

ggplot(data = trasthhev1) +
  geom_line(aes(x = v1hradau, y = v1v2), color = 'blue') +
  scale_y_continuous(trans = 'log10')

ggplot(data = trasthhev2) +
  geom_line(aes(x = v2hradau, y = v2v2), color = 'green') +
  scale_y_continuous(trans = 'log10')


# Combine Trajectory and Cosmic Ray data from Voyager 1 and 2 into one set
#
setkey(trasthhev1, v1hradau)
setkey(trasthhev2, v2hradau)
trasthhe <- trasthhev1[ trasthhev2, roll = "nearest" ]

ggplot(data = trasthhe) +
  geom_line(aes(x = v1hradau, y = v1v2), color = 'blue') +
  geom_line(aes(x = v1hradau, y = v2v2), color = 'green') +
  scale_y_continuous(trans = 'log10')
