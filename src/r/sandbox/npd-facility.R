# Exploring Facility data from Norwegian Petroleum Directorate (NPD) www.npd.no
# https://www.npd.no/en/about-us/information-services/open-data/map-services/
#

# Libraries
library(rnaturalearth)
library(rnaturalearthdata)
library(tidyverse)
library(ggspatial)
library(mapview)
library(biogeo)     # for dms2dd
#library(sf)

world <- ne_countries(scale = "medium", returnclass = "sf")

# Load the data
npdfacility <- read.csv('var/npd/facility/fclPoint.csv', fileEncoding = 'UTF-8')

# Filter
npdfacility <- npdfacility %>% filter(
  !is.na(fclNsDeg), !is.na(fclEwDeg),
  !is.na(fclNsMin), !is.na(fclEwMin),
  !is.na(fclNsSec), !is.na(fclEwSec))

# Geometry
npdfacility <- npdfacility %>% mutate(
  longitude = dms2dd(fclEwDeg, fclEwMin, fclEwSec, fclEwCode),
  latitude = dms2dd(fclNsDeg, fclNsMin, fclNsSec, fclNsCode))

# Change surface to boolean
npdfacility <- npdfacility %>% mutate(
  surface = fclSurface == 'Y')

# Only select interesting columns
npdfacility <- npdfacility %>% select(
  type = fclFixedOrMoveable,
  name = fclName,
  kind = fclKind,
  phase = fclPhase,
  status = fclStatus,
  hemisphere = fclUtmHemisphere,
  zone = fclUtmZone,
  depth = fclWaterDepth,
  startup = fclStartupDate,
  lifetime = fclDesignLifetime,
  surface,
  belongsname = fclBelongsToName,
  belongskind = fclBelongsToKind,
  operator = fclCurrentOperatorName,
  resp = fclCurrentRespCompanyName,
  code = fclNationCode2,
  nation = fclNationName,
  updated = fclDateUpdated,
  functions = fclFunctions,
  longitude,
  latitude)

#mapView(npdfacility, xcol = 'ns', ycol = 'ew')

ggplot(data = world) +
  geom_sf() +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(
    location = "bl",
    which_north = "true", 
    pad_x = unit(0.75, "in"),
    pad_y = unit(0.5, "in"),
    style = north_arrow_fancy_orienteering) +
  geom_point(
    data = npdfacility,
    aes(x = longitude, y = latitude, color = code, shape = type)) +
  coord_sf(xlim = c(-4, 22), ylim = c(43, 73))
