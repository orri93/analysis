# Normalizing

l <- 0.2 # Lower
u <- 1.5 # Upper

x <- c(0.1, 0.2, 0.3, 0.5, 0.8, 1.0, 1.2, 1.3, 1.5, 1.6)

for (i in x) {
  n <- (i - l) / (u - l)
  print(n)
}
