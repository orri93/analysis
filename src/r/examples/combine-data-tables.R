# Combine data test in R
#

# Dependencies
library(dplyr)
library(data.table)

# Create the data
a <- data.table(
  x = c(38,42,39,10,15,30,12,22,61,44,52,60,53,51),
  n = c(6,8,7,1,3,5,2,4,14,9,11,13,12,10))
b <- data.table(
  x = c(10,30,2,9,8,56,60,61,62,15,28,55,49,57),
  d = c('D','G','A','C','B','J','L','M','N','E','F','I','H','K')
)

# Order by x
# oa <- a[order(rank(x))]
# ob <- b[order(rank(x))]
# The nearest will order the table


#
# Combine by x
#

# Set key for all tables to x
setkey(a, x)
setkey(b, x)
# setkey(oa, x)
# setkey(ob, x)

cab <- a[b, roll = "nearest"]
cba <- b[a, roll = "nearest"]

# coab <- oa[ob, roll = "nearest"]
# coba <- ob[oa, roll = "nearest"]
