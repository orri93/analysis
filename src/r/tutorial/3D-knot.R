# Library rgl
library(rgl)

#Choose the size of the image on the output (800,650 to have 800 x 600)
r3dDefaults$windowRect <- c(0,50, 800, 650) 
open3d()

#If you want to put line on the background
#bg3d(sphere = TRUE, color = c("grey", "white"), lit = TRUE, back = "lines" ,lwd=2)

# This is to output a rgl plot in a rmarkdown document. Note that you must add webgl=TRUE, results='hide' in the chunck header
library(knitr)
knit_hooks$set(webgl = hook_webgl)


# plot
bg3d( col=rgb(0.2,0.8,0.5,0.8) )
theta <- seq(0, 2*pi, len = 50)
knot <- cylinder3d(
  center = cbind(sin(theta) + 3*sin(2*theta), 2*sin(3*theta), cos(theta) - 2*cos(2*theta)),
  e1 = cbind(cos(theta) + 4*cos(2*theta),6*cos(3*theta),sin(theta) + 4*sin(2*theta)),radius = 0.9,closed = TRUE)
shade3d(addNormals(subdivision3d(knot, depth = 2)), col = rgb(0.4,0.2,0.8,0.3))

# save it as png
# rgl.snapshot( "~/Desktop/#20_portfolio_knot_3D.png", fmt="png", top=TRUE  )


# Export as an html file if needed:
# writeWebGL( filename="HtmlWidget/3dknot.html" ,  width=600, height=600)
writeWebGL( filename="3dknot.html" ,  width=600, height=600)
