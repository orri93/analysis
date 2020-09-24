process <- function(datafilepath, splinecount = 100, window = 10, xmax = -1, ymax = 255, xlm = 1000, ylm = 10) {
  
  require(zoo)
  
  dcsv <- read.csv(datafilepath)
  
  # Logit = 'y ~ 1/(1 + exp((-Alpha) - Beta * log10(x)))'
  # Logit_three = 'y ~ Gamma / (1 + exp((-Alpha) - Beta * log10(x)))'
  # Logit_four = 'y ~ Delta + (Gamma - Delta) / (1 + exp((-Alpha) - Beta * log10(x)))'
  
  #fx <- function(ps, xx) 1 / (1 + exp(-ps$L - ps$b * log10(xx)))
  fx <- function(ps, xx) ps$L / (1 + exp( - ps$k * (xx - ps$x0))) 
  
  rf <- function(p, observed, xx) observed - fx(p, xx)
  
  time <- dcsv[[1]]
  control <- dcsv[[2]]
  temperature <- dcsv[[3]]
  
  mtime = rollmean(time, window)
  mcontrol = rollmean(control, window)
  mtemperature <- rollmean(temperature, window)
  
  if(xmax < 0) {
    xmax <- max(mtime)
  }
  
  spl <- spline(mtime, mtemperature, splinecount);

  plot(mtime, mcontrol, xlab="time", ylab="temperature", xlim=c(0, xmax), ylim=c(0,ymax), col='blue', pch=1)
  par(new=TRUE)
  plot(mtime, mtemperature, xlab="time", ylab="temperature", xlim=c(0, xmax), ylim=c(0,ymax), col='green', pch=16)
  par(new=TRUE)
  plot(spl$x, spl$y, xlab="time", ylab="spline", xlim=c(0, xmax), ylim=c(0,ymax), col='red', pch=8)
  legend(x=xmax - xlm, y=ymax - ylm, legend=c('control', 'temperature'), col=c('blue', 'red'), pch=c(8,16))

  
  
  
}
