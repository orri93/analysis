# 3d scatterplot with R
# See https://www.r-graph-gallery.com/3d_scatter_plot.html

# library
library(rgl)

# This is to output a rgl plot in a rmarkdown document. Note that you must add webgl=TRUE, results='hide' in the chunck header
#library(knitr)
#knit_hooks$set(webgl = hook_webgl)

# Data: the iris data is provided by R
data <- iris

# Add a new column with color
mycolors <- c('royalblue1', 'darkcyan', 'oldlace')
data$color <- mycolors[ as.numeric(data$Species) ]

# Plot
par(mar=c(0,0,0,0))
plot3d( 
  x=data$`Sepal.Length`, y=data$`Sepal.Width`, z=data$`Petal.Length`, 
  col = data$color, 
  type = 's', 
  radius = .1,
  xlab="Sepal Length", ylab="Sepal Width", zlab="Petal Length")

writeWebGL(filename = 'tmp/3dscatter.html',  width=600, height=600)
