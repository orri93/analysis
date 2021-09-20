# Play with Neural Network Models in R for the famous iris data set 
#

# load library
library(neuralnet)
library(dplyr)

ds <- iris

# create a list of 80% of the rows in the original dataset we can use for training
validation_index <- createDataPartition(ds$Species, p=0.80, list=FALSE)
# select 20% of the data for validation
validation <- ds[-validation_index,]
# use the remaining 80% of data to training and testing the models
training <- ds[validation_index,]

# fit neural network
#h <- 3
h <- c(4,3)
act_fct <- "logistic"
nn=neuralnet(Species~Sepal.Length+Sepal.Width+Petal.Length+Petal.Width, data=training, hidden = h, act.fct = act_fct, linear.output = FALSE)


plot(nn)


## Prediction using neural network
Predict=neuralnet::compute(nn, validation)
Predict$net.result

result <- validation %>% mutate(
  p_setosa = Predict$net.result[,1],
  p_versicolor = Predict$net.result[,2],
  p_virginica = Predict$net.result[,3]
)

result <- result %>% mutate(pm = pmax(
  p_setosa,
  p_versicolor,
  p_virginica))
result <- result %>% mutate(prediction = case_when(
  pm == p_setosa ~ "setosa",
  pm == p_versicolor ~ "versicolor",
  pm == p_virginica ~ "virginica",
  TRUE ~ ""))
result <- result %>% mutate(correct = prediction == Species)
