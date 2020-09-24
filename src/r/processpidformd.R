processpidformd <- function(datafilepath, iscale = 0.1, yl = -1, xl = -1, ymax = -1, xmax = -1, w = -1) {
  
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
  
  data_list <- list(
    "time" = time,
    "kp" = kp,
    "ki" = ki,
    "kd" = kd,
    "setpoint" = setpoint,
    "output" = output,
    "temperature" = temperature,
    "error" = error,
    "integral" = integral,
    "derivative" = derivative,
    "scaled_integral" = scaled_integral)
  
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
  
  timescale_list <- list("minimum" = min(time), "maximum" = max(time))
  
  calculations_list <- list(
    "timescale" = timescale_list,
    "count" = count,
    "fixed_setpoint" = fixed_setpoint,
    "maximum_temperature" = maximum_temperature,
    "overtime" = overtime,
    "undertime" = undertime,
    "startindex" = startindex,
    "diffcount" = diffcount,
    "diffsqsum" = diffsqsum,
    "diffsqavr" = diffsqavr,
    "diffsqrt" = diffsqrt,
    "peak_error" = maximum_temperature - fixed_setpoint)
  
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
  
  plot_list <- list(
    "ymax" = ymax,
    "xmax" = xmax,
    "yl" = yl,
    "xl" = xl,
    "limx" = limx,
    "limy" = limy,
    "leg" = leg,
    "cols" = cols,
    "pchs" = pchs,
    "labx" = labx,
    "laby" = laby,
    "title"= "PID result",
    "sub" = datafilepath)
  
  result_list <- list(
    "data" = data_list,
    "calculations" = calculations_list,
    "plot" = plot_list)
  
  return(result_list)
}