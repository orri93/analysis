# Straight lines to a plot : horizontal, vertical and regression lines
# see http://www.sthda.com/english/wiki/ggplot2-add-straight-lines-to-a-plot-horizontal-vertical-and-regression-lines

# Dependencies
library(grid)
library(ggplot2)
require(stats)


#
# Horizontal lines
#
# Simple scatter plot
sp <- ggplot(data = mtcars, aes(x = wt, y = mpg)) + geom_point()
# Add horizontal line at y = 2O
sp + geom_hline(yintercept=20)
# Change line type and color
sp + geom_hline(yintercept=20, linetype="dashed", color = "red")
# Change line size
sp + geom_hline(yintercept=20, linetype="dashed", color = "red", size=2)


#
# Vertical lines
#
# Add a vertical line at x = 3
sp + geom_vline(xintercept = 3)
# Change line type, color and size
sp + geom_vline(xintercept = 3, linetype="dotted", color = "blue", size=1.5)


#
# Regression lines
#
reg<-lm(mpg ~ wt, data = mtcars)
reg
coeff = coefficients(reg)
# Equation of the line : 
eq = paste0("y = ", round(coeff[2],1), "*x + ", round(coeff[1],1))
# Plot
sp + geom_abline(intercept = 37, slope = -5) + ggtitle(eq)
# Change line type, color and size
sp + geom_abline(intercept = 37, slope = -5, color="red", linetype="dashed", size=1.5) + ggtitle(eq)

sp + stat_smooth(method = 'lm', se = FALSE)


#
# Line segment
#
# Add a vertical line segment
sp + geom_segment(aes(x = 4, y = 15, xend = 4, yend = 27))
# Add horizontal line segment
sp + geom_segment(aes(x = 2, y = 15, xend = 3, yend = 15))

sp + geom_segment(aes(x = 5, y = 30, xend = 3.5, yend = 25),
                  arrow = arrow(length = unit(0.5, "cm")))
