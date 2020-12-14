# Following Online Tutorial
# Drawing beautiful maps programmatically with R, sf and ggplot2
# See https://www.r-spatial.org/r/2018/10/25/ggplot2-sf.html

# Installing
# install.packages('sf')
# install.packages('maps')
# install.packages('tools')
# install.packages('cowplot')
# install.packages('ggplot2')
# install.packages('ggrepel')
# install.packages('ggspatial')
# install.packages('googleway')
# install.packages('rnaturalearth')
# install.packages('rnaturalearthdata')
# install.packages('libwgeom')
# install.packages('lwgeom')

# We start by loading the basic packages necessary for all maps,
# i.e. ggplot2 and sf
library(ggplot2)
library(sf)

library(ggrepel)

# The package rnaturalearth provides a map of countries of the entire world.
# Use ne_countries to pull country data and choose the scale
# (rnaturalearthhires is necessary for scale = "large").
library(rnaturalearth)
library(rnaturalearthdata)

# Several packages are available to create a scale bar on a map
# (e.g. prettymapr, vcd, ggsn, or legendMap). We introduce here the package
# ggspatial, which provides easy-to-use functions…
library(ggspatial)

# It would be informative to add finer administrative information on top of the
# previous map, starting with state borders and names. The package maps (which
# is automatically installed and loaded with ggplot2) provides maps of the USA,
# with state and county borders, that can be retrieved and converted as
# sf objects:
library(maps)

# Note the warning, which basically says that centroid coordinates using
# longitude/latitude data (i.e. WGS84) are not exact, which is perfectly fine
# for our drawing purposes. State names, which are not capitalized in the data
# from maps, can be changed to title case using the function toTitleCase from
# the package tools:
library(tools)

# Instead of looking up coordinates manually, the package googleway provides
# a function google_geocode, which allows to retrieve geographic coordinates
# for any address, using the Google Maps API. Unfortunately, this requires a
# valid Google API key (follow instructions here to get a key, which needs to
# include “Places” for geocoding). Once you have your API key, you can run the
# following code to automatically retrieve geographic coordinates of
# the five cities:
library(googleway)

# An alternative using the function ggdraw from the package cowplot allows to
# use relative positioning in the entire plot device.
library(cowplot)


# We also suggest to use the classic dark-on-light theme for
# ggplot2 (theme_bw), which is appropriate for maps
theme_set(theme_bw())

# The function can return sp classes (default) or directly sf classes,
# as defined in the argument returnclass
world <- ne_countries(scale = "medium", returnclass = "sf")
class(world)

#
# Data and basic
#

# First, let us start with creating a base map of the world using ggplot2.
# This base map will then be extended with different map elements, as well
# as zoomed in to an area of interest. We can check that the world map was
# properly retrieved and converted into an sf object, and plot it with ggplot2
ggplot(data = world) + geom_sf()

# This call nicely introduces the structure of a ggplot call: The first part
# ggplot(data = world) initiates the ggplot graph, and indicates that the main
# data is stored in the world object. The line ends up with a + sign, which
# indicates that the call is not complete yet, and each subsequent line
# correspond to another layer or scale. In this case, we use the geom_sf
# function, which simply adds a geometry stored in a sf object. By default,
# all geometry functions use the main data defined in ggplot(), but we will see
# later how to provide additional data.

# Note that layers are added one at a time in a ggplot call, so the order of
# each layer is very important. All data will have to be in an sf format to be
# used by ggplot2; data in other formats (e.g. classes from sp) will be
# manually converted to sf classes if necessary.

# Title, subtitle, and axis labels
#

# A title and a subtitle can be added to the map using the function ggtitle,
# passing any valid character string (e.g. with quotation marks) as arguments.
# Axis names are absent by default on a map, but can be changed to something
# more suitable (e.g. “Longitude” and “Latitude”), depending on the map:
ggplot(data = world) +
  geom_sf() +
  xlab("Longitude") + ylab("Latitude") +
  ggtitle("World map", subtitle = paste0("(", length(unique(world$NAME)), " countries)"))

# Map color
#

# In many ways, sf geometries are no different than regular geometries, and can
# be displayed with the same level of control on their attributes. Here is
# an example with the polygons of the countries filled with a green
# color (argument fill), using black for the outline of
# the countries (argument color):
ggplot(data = world) + 
  geom_sf(color = "black", fill = "lightgreen")

# The package ggplot2 allows the use of more complex color schemes, such as
# a gradient on one variable of the data. Here is another example that shows
# the population of each country. In this example, we use the “viridis”
# colorblind-friendly palette for the color gradient (with option = "plasma"
# for the plasma variant), using the square root of the population (which is
# stored in the variable POP_EST of the world object):
ggplot(data = world) +
  geom_sf(aes(fill = pop_est)) +
  scale_fill_viridis_c(option = "plasma", trans = "sqrt")

#
# Projection and extent
#

# The function coord_sf allows to deal with the coordinate system, which
# includes both projection and extent of the map. By default, the map will use
# the coordinate system of the first layer that defines one (i.e. scanned in
# the order provided), or if none, fall back on WGS84 (latitude/longitude,
# the reference system used in GPS). Using the argument crs, it is possible
# to override this setting, and project on the fly to any projection.
# This can be achieved using any valid PROJ4 string (here, the European-centric
# ETRS89 Lambert Azimuthal Equal-Area projection):
ggplot(data = world) +
  geom_sf() +
  coord_sf(crs = "+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +units=m +no_defs ")

# Spatial Reference System Identifier (SRID) or an European Petroleum Survey
# Group (EPSG) code are available for the projection of interest, they can be
# used directly instead of the full PROJ4 string. The two following calls are
# equivalent for the ETRS89 Lambert Azimuthal Equal-Area projection,
# which is EPSG code 3035:
ggplot(data = world) +
  geom_sf() +
  coord_sf(crs = "+init=epsg:3035")
ggplot(data = world) +
  geom_sf() +
  coord_sf(crs = st_crs(3035))

# The extent of the map can also be set in coord_sf, in practice allowing
# to “zoom” in the area of interest, provided by limits on the x-axis (xlim),
# and on the y-axis (ylim). Note that the limits are automatically expanded by
# a fraction to ensure that data and axes don’t overlap; it can also be turned
# off to exactly match the limits provided with expand = FALSE:
ggplot(data = world) +
  geom_sf() +
  coord_sf(xlim = c(-102.15, -74.12), ylim = c(7.65, 33.97), expand = FALSE)

#
# Scale bar and North arrow
#

# scale_bar that allows to add simultaneously the north symbol and a scale bar
# into the ggplot map. Five arguments need to be set manually: lon, lat,
# distance_lon, distance_lat, and distance_legend. The location of the scale
# bar has to be specified in longitude/latitude in the lon and lat arguments.
# The shaded distance inside the scale bar is controlled by the distance_lon
# argument. while its width is determined by distance_lat. Additionally, it is
# possible to change the font size for the legend of the scale bar (argument
# legend_size, which defaults to 3). The North arrow behind the “N” north
# symbol can also be adjusted for its length (arrow_length), its distance to
# the scale (arrow_distance), or the size the N north symbol itself
# (arrow_north_size, which defaults to 6). Note that all distances
# (distance_lon, distance_lat, distance_legend, arrow_length, arrow_distance)
# are set to "km" by default in distance_unit; they can also be set to nautical
# miles with “nm”, or miles with “mi”.
ggplot(data = world) +
  geom_sf() +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering) +
  coord_sf(xlim = c(-102.15, -74.12), ylim = c(7.65, 33.97))

# Note the warning of the inaccurate scale bar: since the map use unprojected
# data in longitude/latitude (WGS84) on an equidistant cylindrical projection
# (all meridians being parallel), length in (kilo)meters on the map directly
# depends mathematically on the degree of latitude. Plots of small regions or
# projected data will often allow for more accurate scale bars.

#
# Country names and other names
#

# The world data set already contains country names and the coordinates of the
# centroid of each country (among more information). We can use this
# information to plot country names, using world as a regular data.frame in
# ggplot2. The function geom_text can be used to add a layer of text to a map
# using geographic coordinates. The function requires the data needed to enter
# the country names, which is the same data as the world map. Again, we have a
# very flexible control to adjust the text at will on many aspects:

# * The size (argument size);
# * The alignment, which is centered by default on the coordinates provided.
#   The text can be adjusted horizontally or vertically using the arguments
#   hjust and vjust, which can either be a number between 0 (right/bottom) and
#   1 (top/left) or a character (“left”, “middle”, “right”, “bottom”, “center”,
#   “top”). The text can also be offset horizontally or vertically with the
#   argument nudge_x and nudge_y;
# * The font of the text, for instance its color (argument color) or the type
#   of font (fontface);
# * The overlap of labels, using the argument check_overlap, which removes
#   overlapping text. Alternatively, when there is a lot of overlapping labels,
#   the package ggrepel provides a geom_text_repel function that moves label
#   around so that they do not overlap.
# * For the text labels, we are defining the centroid of the counties with
#   st_centroid, from the package sf. Then we combined the coordinates with the
#   centroid, in the geometry of the spatial data frame. The package sf is
#   necessary for the command st_centroid.

# Additionally, the annotate function can be used to add a single character
# string at a specific location, as demonstrated here to add the Gulf
# of Mexico:
world_points <- st_centroid(world)
world_points <- cbind(world, st_coordinates(st_centroid(world$geometry)))

ggplot(data = world) +
  geom_sf() +
  geom_text(data= world_points,aes(x=X, y=Y, label=name),
            color = "darkblue", fontface = "bold", check_overlap = FALSE) +
  annotate(geom = "text", x = -90, y = 26, label = "Gulf of Mexico", 
           fontface = "italic", color = "grey22", size = 6) +
  coord_sf(xlim = c(-102.15, -74.12), ylim = c(7.65, 33.97), expand = FALSE)

#
# Final map
#

# Now to make the final touches, the theme of the map can be edited to make it
# more appealing. We suggested the use of theme_bw for a standard theme, but
# there are many other themes that can be selected from (see for instance
# ?ggtheme in ggplot2, or the package ggthemes which provide several useful
# themes). Moreover, specific theme elements can be tweaked to get to the final
# outcome:

# * Position of the legend: Although not used in this example, the argument
#   legend.position allows to automatically place the legend at a specific
#   location (e.g. "topright", "bottomleft", etc.);
# * Grid lines (graticules) on the map: by using panel.grid.major and
#   panel.grid.minor, grid lines can be adjusted. Here we set them to a gray
#   color and dashed line type to clearly distinguish them from country
#   borders lines;
# * Map background: the argument panel.background can be used to color the
#   background, which is the ocean essentially, with a light blue;
# * Many more elements of a theme can be adjusted, which would be too long to
#   cover here. We refer the reader to the documentation for the function theme.

ggplot(data = world) +
  geom_sf(fill = "antiquewhite") +
  geom_text(data = world_points, aes(x = X, y = Y, label=name), color = "darkblue", fontface = "bold", check_overlap = FALSE) +
  annotate(geom = "text", x = -90, y = 26, label = "Gulf of Mexico", fontface = "italic", color = "grey22", size = 6) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(location = "bl", which_north = "true", pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"), style = north_arrow_fancy_orienteering) +
  coord_sf(xlim = c(-102.15, -74.12), ylim = c(7.65, 33.97), expand = FALSE) +
  xlab("Longitude") +
  ylab("Latitude") +
  ggtitle("Map of the Gulf of Mexico and the Caribbean Sea") +
  theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", size = 0.5), panel.background = element_rect(fill = "aliceblue"))

#
# Saving the map with ggsave
#

# The final map now ready, it is very easy to save it using ggsave.
# This function allows a graphic (typically the last plot displayed) to be
# saved in a variety of formats, including the most common PNG (raster bitmap)
# and PDF (vector graphics), with control over the size and resolution of the
# outcome. For instance here, we save a PDF version of the map, which keeps the
# best quality, and a PNG version of it for web purposes:
ggsave("tmp/map.pdf")
ggsave("tmp/map_web.png", width = 6, height = 6, dpi = "screen")

#
# Field sites (point data)
#

# We start by defining two study sites, according to their longitude and
# latitude, stored in a regular data.frame:
(sites <- data.frame(longitude = c(-80.144005, -80.109), latitude = c(26.479005, 26.83)))

# The quickest way to add point coordinates is with the general-purpose
# function geom_point, which works on any X/Y coordinates, of regular data
# points (i.e. not geographic). As such, we can adjust all characteristics of
# points (e.g. color of the outline and the filling, shape, size, etc.),
# for all points, or using grouping from the data (i.e defining their
# “aesthetics”). In this example, we add the two points as diamonds
# (shape = 23), filled in dark red (fill = "darkred") and of bigger
# size (size = 4):
ggplot(data = world) +
  geom_sf() +
  geom_point(data = sites, aes(x = longitude, y = latitude), size = 4, 
             shape = 23, fill = "darkred") +
  coord_sf(xlim = c(-88, -78), ylim = c(24.5, 33), expand = FALSE)

# A better, more flexible alternative is to use the power of sf: Converting the
# data frame to a sf object allows to rely on sf to handle on the fly the
# coordinate system (both projection and extent), which can be very useful if
# the two objects (here world map, and sites) are not in the same projection.
# To achieve the same result, the projection (here WGS84, which is the CRS
# code #4326) has to be a priori defined in the sf object:
(sites <- st_as_sf(sites, coords = c("longitude", "latitude"), crs = 4326, agr = "constant"))
ggplot(data = world) +
  geom_sf() +
  geom_sf(data = sites, size = 4, shape = 23, fill = "darkred") +
  coord_sf(xlim = c(-88, -78), ylim = c(24.5, 33), expand = FALSE)

# Note that coord_sf has to be called after all geom_sf calls, as to supersede
# any former input.

#
# States (polygon data)
#

# It would be informative to add finer administrative information on top of the
# previous map, starting with state borders and names. The package maps (which
# is automatically installed and loaded with ggplot2) provides maps of the USA,
# with state and county borders, that can be retrieved and converted as
# sf objects:
states <- st_as_sf(map("state", plot = FALSE, fill = TRUE))
head(states)

# State names are part of this data, as the ID variable. A simple (but not
# necessarily optimal) way to add state name is to compute the centroid of each
# state polygon as the coordinates where to draw their names. Centroids are
# computed with the function st_centroid, their coordinates extracted with
# st_coordinates, both from the package sf, and attached to the state object:
states <- cbind(states, st_coordinates(st_centroid(states)))

# Note the warning, which basically says that centroid coordinates using
# longitude/latitude data (i.e. WGS84) are not exact, which is perfectly fine
# for our drawing purposes. State names, which are not capitalized in the data
# from maps, can be changed to title case using the function toTitleCase from
# the package tools:
states$ID <- toTitleCase(states$ID)
head(states)

# To continue adding to the map, state data is directly plotted as an
# additional sf layer using geom_sf. In addition, state names will be added
# using geom_text, declaring coordinates on the X-axis and Y-axis, as well as
# the label (from ID), and a relatively big font size.
ggplot(data = world) +
  geom_sf() +
  geom_sf(data = states, fill = NA) + 
  geom_text(data = states, aes(X, Y, label = ID), size = 5) +
  coord_sf(xlim = c(-88, -78), ylim = c(24.5, 33), expand = FALSE)

# We can move the state names slightly to be able to read better
# “South Carolina” and “Florida”. For this, we create a new variable nudge_y,
# which is -1 for all states (moved slightly South), 0.5 for Florida
# (moved slightly North), and -1.5 for South Carolina (moved further South):
states$nudge_y <- -1
states$nudge_y[states$ID == "Florida"] <- 0.5
states$nudge_y[states$ID == "South Carolina"] <- -1.5

# To improve readability, we also draw a rectangle behind the state name, using
# the function geom_label instead of geom_text, and plot the map again.
ggplot(data = world) +
  geom_sf() +
  geom_sf(data = states, fill = NA) + 
  geom_label(data = states, aes(X, Y, label = ID), size = 5, fontface = "bold", 
             nudge_y = states$nudge_y) +
  coord_sf(xlim = c(-88, -78), ylim = c(24.5, 33), expand = FALSE)


#
# Counties (polygon data)
#

# County data are also available from the package maps, and can be retrieved
# with the same approach as for state data. This time, only counties from
# Florida are retained, and we compute their area using st_area from
# the package sf:
counties <- st_as_sf(map("county", plot = FALSE, fill = TRUE))
counties <- subset(counties, grepl("florida", counties$ID))
counties$area <- as.numeric(st_area(counties))
head(counties)

# County lines can now be added in a very simple way, using a gray outline:
ggplot(data = world) +
  geom_sf() +
  geom_sf(data = counties, fill = NA, color = gray(.5)) +
  coord_sf(xlim = c(-88, -78), ylim = c(24.5, 33), expand = FALSE)

# We can also fill in the county using their area to visually identify the
# largest counties. For this, we use the “viridis” colorblind-friendly palette,
# with some transparency:
ggplot(data = world) +
  geom_sf() +
  geom_sf(data = counties, aes(fill = area)) +
  scale_fill_viridis_c(trans = "sqrt", alpha = .4) +
  coord_sf(xlim = c(-88, -78), ylim = c(24.5, 33), expand = FALSE)

#
# Cities (point data)
#

# To make a more complete map of Florida, main cities will be added to the map.
# We first prepare a data frame with the five largest cities in the state
# of Florida, and their geographic coordinates:
flcities <- data.frame(
  state = rep("Florida", 5),
  city = c("Miami", "Tampa", "Orlando", "Jacksonville", "Sarasota"),
  lat = c(25.7616798, 27.950575, 28.5383355, 30.3321838, 27.3364347),
  lng = c(-80.1917902, -82.4571776, -81.3792365, -81.655651, -82.5306527))

# Instead of looking up coordinates manually, the package googleway provides
# a function google_geocode, which allows to retrieve geographic coordinates
# for any address, using the Google Maps API. Unfortunately, this requires a
# valid Google API key (follow instructions here to get a key, which needs to
# include “Places” for geocoding). Once you have your API key, you can run the
# following code to automatically retrieve geographic coordinates of
# the five cities:
key <- "put_your_google_api_key_here" # real key needed
flcities <- data.frame(
  state = rep("Florida", 5),
  city = c("Miami", "Tampa", "Orlando", "Jacksonville", "Sarasota"))
coords <- apply(flcities, 1, function(x) {
  google_geocode(address = paste(x["city"], x["state"], sep = ", "), key = key)
})
flcities <- cbind(flcities, do.call(rbind, lapply(coords, geocode_coordinates)))

# We can now convert the data frame with coordinates to sf format:
(flcities <- st_as_sf(flcities, coords = c("lng", "lat"), remove = FALSE, crs = 4326, agr = "constant"))

# We add both city locations and names on the map:
ggplot(data = world) +
  geom_sf() +
  geom_sf(data = counties, fill = NA, color = gray(.5)) +
  geom_sf(data = flcities) +
  geom_text(data = flcities, aes(x = lng, y = lat, label = city), 
            size = 3.9, col = "black", fontface = "bold") +
  coord_sf(xlim = c(-88, -78), ylim = c(24.5, 33), expand = FALSE)

# This is not really satisfactory, as the names overlap on the points, and they
# are not easy to read on the grey background. The package ggrepel offers
# a very flexible approach to deal with label placement (with geom_text_repel
# and geom_label_repel), including automated movement of labels in case
# of overlap. We use it here to “nudge” the labels away from land into the see,
# and connect them to the city locations:
ggplot(data = world) +
  geom_sf() +
  geom_sf(data = counties, fill = NA, color = gray(.5)) +
  geom_sf(data = flcities) +
  geom_text_repel(data = flcities, aes(x = lng, y = lat, label = city), 
                  fontface = "bold", nudge_x = c(1, -1.5, 2, 2, -1), nudge_y = c(0.25, 
                                                                                 -0.25, 0.5, 0.5, -0.5)) +
  coord_sf(xlim = c(-88, -78), ylim = c(24.5, 33), expand = FALSE)

#
# Final map
#

# For the final map, we put everything together, having a general background
# map based on the world map, with state and county delineations, state labels,
# main city names and locations, as well as a theme adjusted with titles,
# subtitles, axis labels, and a scale bar:
ggplot(data = world) +
  geom_sf(fill = "antiquewhite1") +
  geom_sf(data = counties, aes(fill = area)) +
  geom_sf(data = states, fill = NA) + 
  geom_sf(data = sites, size = 4, shape = 23, fill = "darkred") +
  geom_sf(data = flcities) +
  geom_text_repel(data = flcities, aes(x = lng, y = lat, label = city), 
                  fontface = "bold", nudge_x = c(1, -1.5, 2, 2, -1), nudge_y = c(0.25, 
                                                                                 -0.25, 0.5, 0.5, -0.5)) +
  geom_label(data = states, aes(X, Y, label = ID), size = 5, fontface = "bold", 
             nudge_y = states$nudge_y) +
  scale_fill_viridis_c(trans = "sqrt", alpha = .4) +
  annotation_scale(location = "bl", width_hint = 0.4) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering) +
  coord_sf(xlim = c(-88, -78), ylim = c(24.5, 33), expand = FALSE) +
  xlab("Longitude") + ylab("Latitude") +
  ggtitle("Observation Sites", subtitle = "(2 sites in Palm Beach County, Florida)") +
  theme(panel.grid.major = element_line(color = gray(0.5), linetype = "dashed", 
                                        size = 0.5), panel.background = element_rect(fill = "aliceblue"))

# This example fully demonstrates that adding layers on ggplot2 is relatively
# straightforward, as long as the data is properly stored in an sf object.
# Adding additional layers would simply follow the same logic, with additional
# calls to geom_sf at the right place in the ggplot2 sequence.


#
# General concepts
#

# There are 2 solutions to combine sub-maps:

# * Using “grobs”, i.e. graphic objects from ggplot2, which can be inserted in
#   the plot region using plot coordinates;
# * Using ggdraw from package cowplot, which allows to arrange new plots
#   anywhere on the graphic device, including outer margins, based on relative
#   position.

# Here is a simple example illustrating the difference between the two,
# and their use. We first prepare a simple graph showing 11 points,
# with regular axes and grid (g1):
(g1  <- qplot(0:10, 0:10))

# Graphs from ggplot2 can be saved, like any other R object. That allows
# to reuse and update the graph later on. For instance, we store in g1_void,
# a simplified version of this graph only the point data, but no decoration:
(g1_void <- g1 + theme_void() + theme(panel.border = element_rect(colour = "black", fill = NA)))

# The function annotation_custom allows to arrange graphs together in the form
# of grobs (generated with ggplotGrob). Here we first plot the full graph g1,
# and then add two instances of g1_void in the upper-left and bottom-right
# corners of the plot region (as defined by xmin, xmax, ymin, and ymax):

# Using grobs, and annotation_custom:
g1 +
  annotation_custom(
    grob = ggplotGrob(g1_void),
    xmin = 0,
    xmax = 3,
    ymin = 5,
    ymax = 10
  ) +
  annotation_custom(
    grob = ggplotGrob(g1_void),
    xmin = 5,
    xmax = 10,
    ymin = 0,
    ymax = 3
  )

# An alternative using the function ggdraw from the package cowplot allows to
# use relative positioning in the entire plot device. In this case, we build
# the graph on top of g1, but the initial call to ggdraw could actually be left
# empty to arrange subplots on an empty plot. Width and height of the subplots
# are relative from 0 to 1, as well x and y coordinates ([0,0] being the lower-
# left corner, [1,1] being the upper-right corner). Note that in this case,
# subplots are not limited to the actual plot region, but can be added anywhere
# on the device:
ggdraw(g1) +
  draw_plot(g1_void, width = 0.25, height = 0.5, x = 0.02, y = 0.48) +
  draw_plot(g1_void, width = 0.5, height = 0.25, x = 0.75, y = 0.09)

#
# Several maps side by side or on a grid
#

# In this section, we present a way to arrange several maps side by side on
# a grid. While this could be achieved manually after exporting each individual
# map, this allows to 1) have reproducible code to this end; 2) full control on
# how individual maps are positioned.

# In this example, a zoom in on the Gulf of Mexico is placed on the side of the
# world map (including its legend). This illustrates how to use a custom grid,
# which can be made a lot more complex with more elements.

# We now prepare the subplots, starting by the world map with a rectangle
# around the Gulf of Mexico (see Section 1 and 2 for the details of how to
# prepare this map):
  
# Prepare the subplots, #1 world map:
(gworld <- ggplot(data = world) +
    geom_sf(aes(fill = region_wb)) +
    geom_rect(xmin = -102.15, xmax = -74.12, ymin = 7.65, ymax = 33.97, 
              fill = NA, colour = "black", size = 1.5) +
    scale_fill_viridis_d(option = "plasma") +
    theme(panel.background = element_rect(fill = "azure"),
          panel.border = element_rect(fill = NA)))

# The second map is very similar, but centered on
# the Gulf of Mexico (using coord_sf):
(ggulf <- ggplot(data = world) +
    geom_sf(aes(fill = region_wb)) +
    annotate(geom = "text", x = -90, y = 26, label = "Gulf of Mexico", 
             fontface = "italic", color = "grey22", size = 6) +
    coord_sf(xlim = c(-102.15, -74.12), ylim = c(7.65, 33.97), expand = FALSE) +
    scale_fill_viridis_d(option = "plasma") +
    theme(legend.position = "none", axis.title.x = element_blank(), 
          axis.title.y = element_blank(), panel.background = element_rect(fill = "azure"), 
          panel.border = element_rect(fill = NA)))

# Finally, we just need to arrange these two maps, which can be easily done
# with annotation_custom. Note that in this case, we use an empty call to
# ggplot to position the two maps on an empty background (of size 3.3 × 1):
ggplot() +
  coord_equal(xlim = c(0, 3.3), ylim = c(0, 1), expand = FALSE) +
  annotation_custom(ggplotGrob(gworld), xmin = 0, xmax = 2.3, ymin = 0, 
                    ymax = 1) +
  annotation_custom(ggplotGrob(ggulf), xmin = 2.3, xmax = 3.3, ymin = 0, 
                    ymax = 1) +
  theme_void()

# The second approach using the function plot_grid from cowplot to arrange
# ggplot figures, is quite versatile. Any ggplot figure can be arranged just
# like the figure above. Several arguments adjust map placement, such as nrow
# and ncol which define the number of row and columns, respectively,
# and rel_widths which establishes the relative width of each map. In our case,
# we want both maps on a single row, the first map gworld to have a relative
# width of 2.3, and the map ggulf a relative width of 1.
plot_grid(gworld, ggulf, nrow = 1, rel_widths = c(2.3, 1))

# The argument align can be used to align subplots horizontally (align = "h"),
# vertically (align = "v"), or both (align = "hv"), so that the axes and plot
# region match each other. Note also the existence of get_legend (cowplot),
# which extract the legend of a plot, which can then be used as any object
# (for instance, to place it precisely somewhere on the map).

# Both maps created above (using ggplot and annotation_custom, or using cowplot
# and plot_grid) can be saved as usual using ggsave (to be used after plotting
# the desired map):
ggsave("tmp/grid.pdf", width = 15, height =  5)

#
# Map insets
#

# To inset maps directly on a background map, both solutions presented earlier
# are viable (and one might prefer one or the other depending on relative or
# absolute coordinates). We will illustrate this using a map of the 50 states
# of the United States, including Alaska and Hawaii (note: both Alaska and
# Hawaii will not be to scale).

# We start by preparing the continental states first, using the reference
# US National Atlas Equal Area projection (CRS 2163). The main trick is to find
# the right coordinates, in the projection used, and this may cause some fine
# tuning at each step. Here, we enlarge the extent of the plot region on
# purpose to give some room for the insets:
usa <- subset(world, admin == "United States of America")
(mainland <- ggplot(data = usa) +
    geom_sf(fill = "cornsilk") +
    coord_sf(crs = st_crs(2163), xlim = c(-2500000, 2500000), ylim = c(-2300000, 730000)))

# The Alaska map is plotted using the reference Alaska Albers
# projection (CRS 3467). Note that graticules and coordinates are removed
# with datum = NA:
(alaska <- ggplot(data = usa) +
    geom_sf(fill = "cornsilk") +
    coord_sf(crs = st_crs(3467), xlim = c(-2400000, 1600000), ylim = c(200000, 2500000), expand = FALSE, datum = NA))

# And now the map of Hawaii, plotted using the reference Old
# Hawaiian projection (CRS 4135):
(hawaii  <- ggplot(data = usa) +
    geom_sf(fill = "cornsilk") +
    coord_sf(
      crs = st_crs(4135),
      xlim = c(-161, -154),
      ylim = c(18, 23),
      expand = FALSE,
      datum = NA))

# The final map can be created using ggplot2 only, with the help of
# the function annotation_custom. In this case, we use arbitrary ratios based
# on the size of the subsets above (note the difference based on maximum minus
# minimum x/y coordinates):
mainland +
  annotation_custom(
    grob = ggplotGrob(alaska),
    xmin = -2750000,
    xmax = -2750000 + (1600000 - (-2400000))/2.5,
    ymin = -2450000,
    ymax = -2450000 + (2500000 - 200000)/2.5
  ) +
  annotation_custom(
    grob = ggplotGrob(hawaii),
    xmin = -1250000,
    xmax = -1250000 + (-154 - (-161))*120000,
    ymin = -2450000,
    ymax = -2450000 + (23 - 18)*120000
  )

# The same can be achieved with the same logic using cowplot and the function
# draw_plot, in which case it is easier to define the ratios of Alaska and
# Hawaii first:
(ratioAlaska <- (2500000 - 200000) / (1600000 - (-2400000)))
(ratioHawaii  <- (23 - 18) / (-154 - (-161)))
ggdraw(mainland) +
  draw_plot(alaska, width = 0.26, height = 0.26 * 10/6 * ratioAlaska, 
            x = 0.05, y = 0.05) +
  draw_plot(hawaii, width = 0.15, height = 0.15 * 10/6 * ratioHawaii, 
            x = 0.3, y = 0.05)

# Again, both plots can be saved using ggsave:
ggsave("tmp/map-us-ggdraw.pdf", width = 10, height = 6)

#
# Several maps connected with arrows
#

# To bring about a more lively map arrangement, arrows can be used to direct
# the viewer’s eyes to specific areas in the plot. The next example will create
# a map with zoomed in areas, connected by arrows.

# We start by creating the general map, here a map of Florida with the site
# locations (see Tutorial 2 for the details):
sites <- st_as_sf(data.frame(
  longitude = c(-80.15, -80.1),
  latitude = c(26.5, 26.8)),
  coords = c("longitude", "latitude"),
  crs = 4326, agr = "constant")
(florida <- ggplot(data = world) +
    geom_sf(fill = "antiquewhite1") +
    geom_sf(data = sites, size = 4, shape = 23, fill = "darkred") +
    annotate(
      geom = "text",
      x = -85.5,
      y = 27.5,
      label = "Gulf of Mexico",
      color = "grey22",
      size = 4.5) +
    coord_sf(xlim = c(-87.35, -79.5), ylim = c(24.1, 30.8)) +
    xlab("Longitude")+ ylab("Latitude")+
    theme(
      panel.grid.major = element_line(colour = gray(0.5), linetype = "dashed", size = 0.5),
      panel.background = element_rect(fill = "aliceblue"),
      panel.border = element_rect(fill = NA)))

# We then prepare two study sites (simply called A and B here):
(siteA <- ggplot(data = world) +
    geom_sf(fill = "antiquewhite1") +
    geom_sf(data = sites, size = 4, shape = 23, fill = "darkred") +
    coord_sf(xlim = c(-80.25, -79.95), ylim = c(26.65, 26.95), expand = FALSE) + 
    annotate("text", x = -80.18, y = 26.92, label= "Site A", size = 6) + 
    theme_void() + 
    theme(
      panel.grid.major = element_line(colour = gray(0.5), linetype = "dashed", size = 0.5),
      panel.background = element_rect(fill = "aliceblue"),
      panel.border = element_rect(fill = NA)))

(siteB <- ggplot(data = world) + 
    geom_sf(fill = "antiquewhite1") +
    geom_sf(data = sites, size = 4, shape = 23, fill = "darkred") +
    coord_sf(xlim = c(-80.3, -80), ylim = c(26.35, 26.65), expand = FALSE) +
    annotate("text", x = -80.23, y = 26.62, label= "Site B", size = 6) + 
    theme_void() +
    theme(
      panel.grid.major = element_line(colour = gray(0.5), linetype = "dashed", size = 0.5),
      panel.background = element_rect(fill = "aliceblue"),
      panel.border = element_rect(fill = NA)))

# As we want to connect the two subplots to main map using arrows,
# the coordinates of the two arrows will need to be specified before plotting.
# We prepare a data.frame storing start and end coordinates (x1 and x2 on
# the x-axis, y1 and y2 on the y-axis):
arrowA <- data.frame(x1 = 18.5, x2 = 23, y1 = 9.5, y2 = 14.5)
arrowB <- data.frame(x1 = 18.5, x2 = 23, y1 = 8.5, y2 = 6.5)

# Using ggplot only, we simply follow the same approach as before to place
# several maps side by side, and then add arrows using the function
# geom_segment and the argument arrow = arrow():
ggplot() +
  coord_equal(xlim = c(0, 28), ylim = c(0, 20), expand = FALSE) +
  annotation_custom(ggplotGrob(florida), xmin = 0, xmax = 20, ymin = 0, 
                    ymax = 20) +
  annotation_custom(ggplotGrob(siteA), xmin = 20, xmax = 28, ymin = 11.25, 
                    ymax = 19) +
  annotation_custom(ggplotGrob(siteB), xmin = 20, xmax = 28, ymin = 2.5, 
                    ymax = 10.25) +
  geom_segment(aes(x = x1, y = y1, xend = x2, yend = y2), data = arrowA, 
               arrow = arrow(), lineend = "round") +
  geom_segment(aes(x = x1, y = y1, xend = x2, yend = y2), data = arrowB, 
               arrow = arrow(), lineend = "round") +
  theme_void()

# The package cowplot (with draw_plot) can also be used for a similar result,
# with maybe a somewhat easier syntax:
ggdraw(xlim = c(0, 28), ylim = c(0, 20)) +
  draw_plot(florida, x = 0, y = 0, width = 20, height = 20) +
  draw_plot(siteA, x = 20, y = 11.25, width = 8, height = 8) +
  draw_plot(siteB, x = 20, y = 2.5, width = 8, height = 8) +
  geom_segment(aes(x = x1, y = y1, xend = x2, yend = y2), data = arrowA, 
               arrow = arrow(), lineend = "round") +
  geom_segment(aes(x = x1, y = y1, xend = x2, yend = y2), data = arrowB, 
               arrow = arrow(), lineend = "round")

# Again, both plot can be saved using ggsave:
ggsave("tmp/florida-sites.pdf", width = 10, height = 7)
