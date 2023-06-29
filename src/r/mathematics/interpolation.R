#
# Interpolation using line equation between two points
#

# Given two points

x1 <- 2
y1 <- 3

x2 <- 6
y2 <- 8

# Finding the eq. of a line in slope-intercept form
m <- (y2 - y1) / (x2 - x1)
b1 <- y1 - m * x1
b2 <- y2 - m * x2

# Gives y = m * x + b

plot(c(x1, x2), c(y1,x2))

curve(expr = m * x + b1, from = -2, to = 10)


#
# General interpolation
#
interpolate_linear <- function(y1, y2, mu) {
  return (y1 * (1.0 - mu) + y2 * mu)
}

interpolate_linear(1.0, 2.0, -1.0)
interpolate_linear(1.0, 2.0, 0.0)
interpolate_linear(1.0, 2.0, 0.5)
interpolate_linear(1.0, 2.0, 0.25)
interpolate_linear(1.0, 2.0, 0.75)
interpolate_linear(1.0, 2.0, 1.0)
