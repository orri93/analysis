# A complete guide to 3D visualization device system in R - R software and data visualization
# http://www.sthda.com/english/wiki/a-complete-guide-to-3d-visualization-device-system-in-r-r-software-and-data-visualization
#

# Dependencies
library(sphereplot)
library(rgl)

# We’ll use the iris data set in the following examples:
data(iris)
head(iris)

x <- sep.l <- iris$Sepal.Length
y <- pet.l <- iris$Petal.Length
z <- sep.w <- iris$Sepal.Width

