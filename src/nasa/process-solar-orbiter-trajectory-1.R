# Process NASA Solar Orbiter Trajectory data
#

# Dependencies
library(tidyverse)
library(lubridate)
library(sphereplot)
library(rgl)

# Read Data

# Read Trajectory data
rtraj <- read.csv('tmp/nasa/spdf/solar-orbiter/helio1day/solo_helio1day_position_20200211_v01.csv')

# Convert date time
traj <- rtraj %>% mutate(ts = as_datetime(time / 1000))

# Transforms 3D spherical coordinates to Cartesian coordinates.
cart <- sph2car(traj$lon, traj$lat, traj$rad)

# Plot trajectory
plot3d(cart)
