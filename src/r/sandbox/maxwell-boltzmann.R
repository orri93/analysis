# Maxwell-Boltzmann Distribution
# https://en.wikipedia.org/wiki/Maxwell%E2%80%93Boltzmann_distribution
# https://www.rdocumentation.org/packages/rotations/versions/1.6.1/topics/Maxwell

# Dependencies
library(tidyverse)
library(rotations)

# The Modified Maxwell-Boltzmann Distribution
r <- seq(-pi, pi, length = 500)

f0 <- dmaxwell(r, kappa = 0.5)
f1 <- dmaxwell(r, kappa = 1)
f2 <- dmaxwell(r, kappa = 2)
f3 <- dmaxwell(r, kappa = 3)

dn1 <- dnorm(r, mean = 0, sd = 1)
dn2 <- dnorm(r, mean = 0, sd = 2)
dn3 <- dnorm(r, mean = 0, sd = 3)

data <- data.frame(r, f0, f1, f2, f3, dn1, dn2, dn3)

ggplot(data = data) +
  geom_line(mapping = aes(x = r, y = f1), color = 'green') +
  geom_line(mapping = aes(x = r, y = f2), color = 'red') +
  geom_line(mapping = aes(x = r, y = f3), color = 'blue')

ggplot(data = data) +
  geom_line(mapping = aes(x = r, y = f0), color = 'red') +
  geom_line(mapping = aes(x = r, y = dn1), color = 'blue')
