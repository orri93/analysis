# Process NASA Pioneer 10 Jupiter Trajectory data
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
# https://spdf.gsfc.nasa.gov/pub/data/pioneer/pioneer10/traj/jupiter/p10trjjup_fmt.txt
rtraj <- fread("https://spdf.gsfc.nasa.gov/pub/data/pioneer/pioneer10/traj/jupiter/p10trjjup.asc")

# Convert date time
traj <- rtraj %>% mutate(ts = date_decimal(V1) + as.duration(86400 * V2))

# Select and rename
traj <- traj %>% select(ts, srange = V3, seclat = V4, seclon = V5, prange = V6, peqlat = V7, peqlon = V8)

# Transforms 3D spherical coordinates to Cartesian coordinates.
scart <- sph2car(traj$seclon, traj$seclat, traj$srange)
pcart <- sph2car(traj$peqlon, traj$peqlat, traj$prange)

# Plot both trajectory
plot3d(scart)
plot3d(pcart)
