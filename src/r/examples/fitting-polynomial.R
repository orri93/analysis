# Fitting Polynomial Regression in R
# https://datascienceplus.com/fitting-polynomial-regression-r/
# http://www.sthda.com/english/articles/40-regression-analysis/166-predict-in-r-model-predictions-and-confidence-intervals/

# Dependencies
library(ggplot2)


# Generate Data
set.seed(20)
q <- seq(from=0, to=20, by=0.1)

# Value to predict (y)
y <- 500 + 0.4 * (q-10)^3

# Some noise is generated and added to the real signal (y)
noise <- rnorm(length(q), mean=10, sd=80)
noisy.y <- y + noise

# Plot of the noisy signal:
plot(q,noisy.y,col='deepskyblue4',xlab='q',main='Observed data')
lines(q,y,col='firebrick1',lwd=3)

# Our model should be something like this: y = a*q + b*q2 + c*q3 + cost
# Let’s fit it using R. When fitting polynomials you can either use
model <- lm(noisy.y ~ poly(q,3))
# or model <- lm(noisy.y ~ x + I(X^2) + I(X^3))

summary(model)

# By using the confint function we can obtain the confidence intervals of the parameters of our model.
confint(model, level=0.95)

# Plot of fitted vs residuals. No clear pattern should show in the residual plot if the model is a good fit
plot(fitted(model),residuals(model))


#
# Overall the model seems a good fit as the R squared of 0.8 indicates.
# The coefficients of the first and third order terms are statistically significant as we expected.
# Now we can use the predict function to get the fitted values and the confidence intervals
# in order to plot everything against our data.
#

# Predicted values and confidence intervals:
predicted.intervals <- predict(model,data.frame(x=q),interval='confidence', level=0.99)

# Add lines to the previous plot
plot(q,noisy.y,col='deepskyblue4',xlab='q',main='Observed data')
lines(q,y,col='firebrick1',lwd=3)
lines(q,predicted.intervals[,1],col='green',lwd=3)
lines(q,predicted.intervals[,2],col='black',lwd=1)
lines(q,predicted.intervals[,3],col='black',lwd=1)

# Add a legend:
legend("bottomright",c("Observ.","Signal","Predicted"), col=c("deepskyblue4","red","green"), lwd=3)


#
# Build a linear regression
#
# Load the data
data("cars", package = "datasets")
# Build the model
model <- lm(dist ~ speed, data = cars)
summary(model)
# The linear model equation can be written as follow: dist = -17.579 + 3.932*speed:
model

# Prediction for new data set
new.speeds <- data.frame(speed = c(12, 19, 24))

# You can predict the corresponding stopping distances using the R function predict as follow
predict(model, newdata = new.speeds)

#
# Confidence interval

# The confidence interval reflects the uncertainty around the mean predictions.
# To display the 95% confidence intervals around the mean the predictions,
# specify the option interval = "confidence":
predict(model, newdata = new.speeds, interval = "confidence")

# The output contains the following columns:
#   * fit: the predicted sale values for the three new advertising budget
#   * lwr and upr: the lower and the upper confidence limits for the expected values,
#     respectively. By default the function produces the 95% confidence limits.

#
# Prediction interval

# The prediction interval gives uncertainty around a single value.
# In the same way, as the confidence intervals, the prediction intervals can be computed as follow:
predict(model, newdata = new.speeds, interval = "prediction")

#
# Prediction interval or confidence interval?

# A prediction interval reflects the uncertainty around a single value,
# while a confidence interval reflects the uncertainty around the mean prediction values.
# Thus, a prediction interval will be generally much wider than a confidence interval for
# the same value.
# Which one should we use? The answer to this question depends on the context and
# the purpose of the analysis. Generally, we are interested in specific individual predictions,
# so a prediction interval would be more appropriate. Using a confidence interval when you should
# be using a prediction interval will greatly underestimate the uncertainty in a given predicted
# value (P. Bruce and Bruce 2017).
# The R code below creates a scatter plot with:
#   * The regression line in blue
#   * The confidence band in gray
#   * The prediction band in red

# 1. Add predictions 
pred.int <- predict(model, interval = "prediction")
mydata <- cbind(cars, pred.int)
# 2. Regression line + confidence intervals
p <- ggplot(mydata, aes(speed, dist)) +
  geom_point() +
  stat_smooth(method = lm)
# 3. Add prediction intervals
p + geom_line(aes(y = lwr), color = "red", linetype = "dashed")+
  geom_line(aes(y = upr), color = "red", linetype = "dashed")
