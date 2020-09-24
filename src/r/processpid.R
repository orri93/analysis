processpid <- function(datafilepath, iscale = 0.1, yl = -1, xl = -1, ymax = -1, xmax = -1, w = -1) {
  
  require(R.utils)
  require(zoo)
  
  dcsv <- read.csv(datafilepath)
  
  if(w < 0) {
    w = 25
  }
  
  time <- dcsv[[1]]
  status <- dcsv[[2]]
  kp <- max(dcsv[[3]])
  ki <- max(dcsv[[4]])
  kd <- max(dcsv[[5]])
  setpoint <- dcsv[[6]]
  output <- dcsv[[7]]
  temperature <- dcsv[[8]]
  error <- dcsv[[9]]
  integral <- dcsv[[10]]
  derivative <- dcsv[[11]]
  
  scaled_integral <- integral * iscale
  
  count <- length(temperature)
  fixed_setpoint <- max(setpoint)
  maximum_temperature <- max(temperature)
  
  mtime = rollmean(time, w)
  mtemperature <- rollmean(temperature, w)
  mcount = length(mtemperature)
  over <- FALSE
  under <- FALSE
  for(i in 1:mcount) {
    if(over && under) {
      break
    } else {
      if(over) {
        if(mtemperature[i] < fixed_setpoint) {
          under <- TRUE
          undertime <- mtime[i]
        }
      } else {
        if(mtemperature[i] > fixed_setpoint) {
          over <- TRUE
          overtime <- mtime[i]
        }
      }
    }
  }
  
  startindex <- -1
  diffcount <- 0
  diffsqsum <- 0
  for(i in 1:count) {
    if(time[i] > undertime) {
      diffcount <- diffcount + 1
      diffsqsum <- diffsqsum + error[i] * error[i]
      if(startindex < 0) {
        startindex = i
      }
    }
  }
  diffsqavr <- diffsqsum / diffcount
  diffsqrt <- sqrt(diffsqavr)
  
  printf("Time scale: %f - %f\n", min(time), max(time))
  printf("Count: %d\n", count)
  
  printf("Kp: %f\n", kp)
  printf("Ki: %f\n", ki)
  printf("Kd: %f\n", kd)
  
  printf("Setpoint: %f\n", fixed_setpoint)
  printf("Maximum Temperature: %f\n", maximum_temperature)
  printf("Peak Error: %f\n", maximum_temperature - fixed_setpoint)
  
  printf("Over time: %f\n", overtime)
  printf("Under time: %f\n", undertime)
  
  printf("Difference variation analysis for index %d to %d or count of %d\n", startindex, count, diffcount)
  
  printf("Difference Squared Sum: %f\n", diffsqsum)
  printf("Difference Squared Avrage: %f\n", diffsqavr)
  printf("Difference Standard: %f\n", diffsqrt)

  if(ymax < 0) {
    ymax = max(fixed_setpoint, max(output), maximum_temperature, max(error), max(scaled_integral), max(derivative))
  }
  if(xmax < 0) {
    xmax <- max(mtime)
  }
  if(yl < 0) {
    yl = ymax - 10
  }
  if(xl < 0) {
    xl = 1000
  }
  limx <- c(0, xmax)
  limy <- c(0, ymax)
  
  leg <- c('temperature','output', 'setpoint', 'error', 'integral', 'derivative')
  cols <- c('chocolate', 'blue', 'green', 'brown', 'darkviolet', 'cyan')
  pchs <- c(1,2,3,4,5,6)
  
  labx <- "time"
  laby <- "temperature"
  
  plot(time, temperature, xlab=labx, ylab=laby, ylim=limy, col='chocolate', pch=1)
  par(new=TRUE)
  plot(time, output, xlab=labx, ylab=laby, ylim=limy, col='blue', pch=2)
  par(new=TRUE)
  plot(time, setpoint, xlab=labx, ylab=laby, ylim=limy, col='green', pch=3)
  par(new=TRUE)
  plot(time, error, xlab=labx, ylab=laby, ylim=limy, col='brown', pch=4)
  par(new=TRUE)
  plot(time, scaled_integral, xlab=labx, ylab=laby, ylim=limy, col='darkviolet', pch=5)
  par(new=TRUE)
  plot(time, derivative, xlab=labx, ylab=laby, ylim=limy, col='cyan', pch=6)
  legend(x=xl, y=yl, legend=leg, col=cols, pch=pchs)
  title(main="PID result", sub=datafilepath)

}
