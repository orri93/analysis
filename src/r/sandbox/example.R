#k <- 5

eiming2 <- read.csv2('var/sandbox/eiming2.csv', header = FALSE, stringsAsFactors = FALSE)

e2v2 <- eiming2$V2
e2v3 <- eiming2$V3
e2v4 <- eiming2$V4
#me2v2 <- runmed(e2v2, k)
#me2v4 <- runmed(e2v4, k)

e2v2t <- hms(e2v2)
e2v2e <- e2v2t - e2v2t[1]

#plot(me2v2, me2v4)

