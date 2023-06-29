# Scaling

sl <- 0.2 # Source Lower
su <- 1.5 # Source Upper

dl <- 2.0 # Destination Lower
du <- 8.0 # Destination Upper

x <- c(0.1, 0.2, 0.3, 0.5, 0.8, 1.0, 1.2, 1.3, 1.5, 1.6)

for (i in x) {
  n <- (i - sl) / (su - sl)
  y <- dl + n * (du - dl)
  print(y)
}
