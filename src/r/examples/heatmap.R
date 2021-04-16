# Heatmap Scatter Plots in R
# See https://www.r-graph-gallery.com/79-levelplot-with-ggplot2.html

# Library
library(plotly)
library(tidyverse)
library(hrbrthemes)
library(viridis)
library(htmlwidgets)


#
# Most basic heatmap
#

# Dummy data
x <- LETTERS[1:20]
y <- paste0('var', seq(1,20))
data <- expand.grid(X = x, Y = y)
data$Z <- runif(400, 0, 5)

# Heatmap
ggplot(data, aes(X, Y, fill = Z)) +
  geom_tile()


#
# Control color palette
#

# Give exteme colors
ggplot(data, aes(X, Y, fill = Z)) +
  geom_tile() +
  scale_fill_gradient(low="white", high="blue") +
  theme_ipsum()

# Color Brewer palette
ggplot(data, aes(X, Y, fill= Z)) + 
  geom_tile() +
  scale_fill_distiller(palette = "RdPu") +
  theme_ipsum()

# Color Brewer palette
ggplot(data, aes(X, Y, fill= Z)) + 
  geom_tile() +
  scale_fill_viridis(discrete=FALSE) +
  theme_ipsum()


#
# From wide input format
#

# Heatmap 
volcano %>%
  # Data wrangling
  as_tibble() %>%
  rowid_to_column(var="X") %>%
  gather(key="Y", value="Z", -1) %>%
  # Change Y to numeric
  mutate(Y=as.numeric(gsub("V","",Y))) %>%
  # Viz
  ggplot(aes(X, Y, fill= Z)) + 
  geom_tile() +
  theme_ipsum() +
  theme(legend.position="none")


#
# Turn it interactive with plotly
#
# new column: text for tooltip:
mutdata <- data %>%
  mutate(text = paste0("x: ", x, "\n", "y: ", y, "\n", "Value: ",round(Z,2), "\n", "What else?"))
# classic ggplot, with text in aes
p <- ggplot(mutdata, aes(X, Y, fill= Z, text=text)) + 
  geom_tile() +
  theme_ipsum()
p
fig <- ggplotly(p, tooltip="text")
fig

# save the widget
saveWidget(fig, file = 'tmp/heatmap.html')
