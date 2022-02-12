# Process NASA Pioneer 10 Missioin Trajectory data
#

# Dependencies
library(tidyverse)
library(lubridate)
library(data.table) # For fread
library(sphereplot)
library(rgl)

# Download Data

# Download Trajectory data
# Format information see
# https://spdf.gsfc.nasa.gov/pub/data/pioneer/pioneer10/traj/ip_project/p10tj_fmt.txt
rtraj <- fread("https://spdf.gsfc.nasa.gov/pub/data/pioneer/pioneer10/traj/ip_project/p10tjall.asc")

# Convert date time
traj <- rtraj %>% mutate(ts = date_decimal(V1) + as.duration(86400 * V2))

# Select and rename
traj <- traj %>% select(
  ts,
  HRANGP = V3,  # Distance from Sun to spacecraft in km
  SECLAT = V4,  # Solar ecliptic latitude and
  SECLON = V5,  # longitude of spacecraft with respect to true-of-date Ecliptic
  HELLAT = V6,  # Heliographic latitude and
  HELLON = V7,  # longitude of spacecraft
  HILLON = V8,  # Heliographic inertial longitude of spacecraft with respect to
                # direction of zero heliographic longitude on 1 Jan. 1854 at 1200 UT
  REARSC = V9)  # Distance from Earth to spacecraft in AU
                # (used to calculate Earth Received Time - UT)

# Transforms 3D spherical coordinates to Cartesian coordinates.
hcart <- sph2car(traj$SECLON, traj$SECLAT, traj$HRANGP)

# Plot both trajectory
plot3d(hcart)
