# Astronomy Calculations
#

# Dependencies
library(dplyr)
library(rgl)

# RGL Initialize function
initialize <- function(new.device = FALSE, bg = "black", width = 800, height = 600) {
  if( new.device | rgl.cur() == 0 ) {
    rgl.open()
    par3d(windowRect = 50 + c(0, 0, width, height))
    rgl.bg(color = bg)
  }
  rgl.clear(type = c("shapes", "bboxdeco"))
  rgl.viewpoint(theta = 15, phi = 20, zoom = 0.7)
}

# Data
earth_moon <- data.frame(
  item = c("Earth", "Moon"),
  distance = c(0, 384399000),
  radius = c(6371000, 1737400),
  color = c("blue", "grey"))

solar_system <- data.frame(
  item = c(
    "Sun",
    "Mercury",
    "Venus",
    "Earth",
    "Mars",
    "Asteroid belt start",
    "Asteroid belt end",
    "Jupiter",
    "Saturn",
    "Uranus",
    "Neptune",
    "Kuiper belt start",
    "Kuiper belt end",
    "Oort cloud start",
    "Oort cloud end",
    "Heliosphere upwind",
    "Heliosphere downwind"),
  type = c(
    "Star",
    "Planet",
    "Planet",
    "Planet",
    "Planet",
    "Boundaries",
    "Boundaries",
    "Planet",
    "Planet",
    "Planet",
    "Planet",
    "Boundaries",
    "Boundaries",
    "Boundaries",
    "Boundaries",
    "Boundaries",
    "Boundaries"),
  distance = c(
    0,
    5.800E10,
    1.0771E11,
    1.4960E11,
    2.3000E11,
    3.4408E11,
    4.9367E11,
    7.7800E11,
    1.4335E12,
    2.8750E12,
    4.4984E12,
    4.4879E12,
    7.4799E12,
    7.4788E12,
    1.4960E13,
    1.3464E13,
    2.9920E13),
  radius = c(
    696342000,
    2439700,
    6051800,
    6371000,
    3389500,
    NA,
    NA,
    69911000,
    58232000,
    25362000,
    24622000,
    NA,
    NA,
    NA,
    NA,
    NA,
    NA),
  color = c(
    "darkgoldenrod",
    "brown",
    "darkorange",
    "blue",
    "darkred",
    "bisque",
    "bisque",
    "coral",
    "chocolate",
    "darkturquoise",
    "darkblue",
    "darkmagenta",
    "darkmagenta",
    "darksalmon",
    "darksalmon",
    "aquamarine",
    "aquamarine"))

# Scale
scale_i <- 0.000001
earth_moon <- earth_moon %>% mutate(
  scaled_i_distance = scale_i * distance,
  scaled_i_radius = scale_i * radius)
scale_ii <- 0.000001
scale_iii <- 0.00000001
solar_system <- solar_system %>% mutate(
  scaled_ii_distance = scale_ii * distance,
  scaled_iii_distance = scale_iii * distance,
  scaled_ii_radius = scale_ii * radius,
  scaled_iii_radius = scale_iii * radius)

# Filter
planets_solar_system <- solar_system %>% filter(type == "Star" | type == "Planet")
inner_solar_system <- planets_solar_system[1:5,]

# Range
earth_moon_max <- max(earth_moon$scaled_i_distance)
inner_solar_system_max <- max(inner_solar_system$scaled_ii_distance)

# Draw the earth moon system
initialize()
rgl.spheres(
  x = earth_moon$scaled_i_distance,
  y = 0,
  z = 0,
  r = earth_moon$scaled_i_radius,
  color = earth_moon$color)
# rgl.lines(c(0, earth_moon_max), c(0,0), c(0,0), color = "azure")

# Draw the inner planets
# initialize()
# rgl.spheres(
#   x = inner_solar_system$scaled_ii_distance,
#   y = 0,
#   z = 0,
#   r = inner_solar_system$scaled_ii_radius,
#   color = inner_solar_system$color)
# rgl.lines(c(0, inner_solar_system_max), c(0,0), c(0,0), color = "azure")
