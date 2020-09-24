d <- read.csv('../../var/tc/standard/191122.csv')
x <- d[[1]]
l <- length(x)

c <- d[[2]]
t <- d[[3]]

plot(x, t, main="Temperature Controller", xlab="Time (s)", ylab="Temperature °C", pch=19)

