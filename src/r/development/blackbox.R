
sd <- 0.125
count <- 1000

minx <- 1.0
maxx <- 5.0

miny <- 0.001
maxy <- 0.01

scalex <- maxx - minx
scaley <- maxy - miny

x <- minx + scalex / 2
y <- miny + scaley / 2

r <- rnorm(count * 2, 0.0, sd)

xv <- numeric(count)
yv <- numeric(count)

rindex <- 1
for(i in 1:count) {
  nx <- x + r[rindex] * scalex;
  if(nx < minx) {
    nx <- minx;
  } else if(nx > maxx) {
    nx <- maxx;
  }
  x <- nx;
  
  ny <- y + r[rindex + 1] * scaley;
  if(ny < miny) {
    ny <- miny
  } else if(ny > maxy) {
    ny <- maxy
  }
  y <- ny
  
  rindex <- rindex + 1
  
  xv[i] <- x
  yv[i] <- y
}

plot(xv, yv)

