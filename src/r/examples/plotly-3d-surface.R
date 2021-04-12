# 3d surface plot with R and plotly
# See https://www.r-graph-gallery.com/3d-surface-plot.html

# Library
library(plotly)
library(htmlwidgets)

# Data: volcano is provided by plotly

# Plot
p <- plot_ly(z = volcano, type = "surface")
# p 

# save the widget
saveWidget(p, file = 'tmp/3dSurface.html')
