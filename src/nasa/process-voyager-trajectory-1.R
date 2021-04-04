# Process NASA Voyager Trajectory data
#

# Dependencies
# library(zoo)
library(tidyverse)
library(lubridate)
library(data.table)
library(sphereplot)
# library(rgl)

# Download Data

# Download Trajectory data
# Format information see 
# https://spdf.gsfc.nasa.gov/pub/data/voyager/voyager1/traj/ssc/vy1trj_ssc_fmt.txt
rtrajv1 <- fread("https://spdf.gsfc.nasa.gov/pub/data/voyager/voyager1/traj/ssc/vy1trj_ssc_1d.asc")
rtrajv2 <- fread("https://spdf.gsfc.nasa.gov/pub/data/voyager/voyager2/traj/ssc/vy2trj_ssc_1d.asc")

# Convert date time
trajv1 <- rtrajv1 %>% mutate(tv1ts = date_decimal(V1) + days(V2))
trajv2 <- rtrajv2 %>% mutate(tv2ts = date_decimal(V1) + days(V2))

# Select and rename
trajv1 <- trajv1 %>% select(tv1ts, v1hradau = V3, v1seclat = V4, v1seclon = V5, v1hellat = V6, v1hellon = V7, v1hillon = V8)
trajv2 <- trajv2 %>% select(tv2ts, v2hradau = V3, v2seclat = V4, v2seclon = V5, v2hellat = V6, v2hellon = V7, v2hillon = V8)

# Transforms 3D spherical coordinates to cartesian coordinates.
carv1 <- sph2car(trajv1$v1seclon, trajv1$v1seclat, trajv1$v1hradau)
carv2 <- sph2car(trajv2$v2seclon, trajv2$v2seclat, trajv2$v2hradau)

# Plot both trajectory
# plot3d(carv1)
# plot3d(carv2)
rgl.open()# Open a new RGL device
par3d(windowRect = 50 + c( 0, 0, 800, 600 ))
rgl.bg(color = "white")
rgl.clear(type = c("shapes", "bboxdeco"))
rgl.viewpoint(theta = 15, phi = 20, zoom = 0.7)
rgl.points(carv1, col = "blue")
rgl.points(carv2, col = "green")
rgl.bbox(color = "#333377")
