# Following the article "Your First Machine Learning Project in R Step-By-Step" byJason Brownlee
#
# see https://machinelearningmastery.com/machine-learning-in-r-step-by-step/
#


# The article uses caret and Seurat
#
# install.packages("caret")
#
library(caret)
library(dplyr)
library(ggplot2)


#
# Load data from csv
#

# load the CSV file from the local directory
# dataset <- read.csv("iris.csv", header=FALSE)
# set the column names in the dataset
# colnames(dataset) <- c("Sepal.Length","Sepal.Width","Petal.Length","Petal.Width","Species")


#
# Load the data
#

# attach the iris dataset to the environment
data(iris)
# rename the dataset
dataset <- iris


#
# Create a Validation Dataset
#

# We need to know that the model we created is any good.

# Later, we will use statistical methods to estimate the accuracy of the models
# that we create on unseen data. We also want a more concrete estimate of
# the accuracy of the best model on unseen data by evaluating it on actual unseen data.

# That is, we are going to hold back some data that the algorithms will not get
# to see and we will use this data to get a second and independent idea of
# how accurate the best model might actually be.

# We will split the loaded dataset into two, 80% of which we will use to train
# our models and 20% that we will hold back as a validation dataset.

# create a list of 80% of the rows in the original dataset we can use for training
validation_index <- createDataPartition(dataset$Species, p=0.80, list=FALSE)
# select 20% of the data for validation
validation <- dataset[-validation_index,]
# use the remaining 80% of data to training and testing the models
dataset <- dataset[validation_index,]

# You now have training data in the dataset variable and a validation set we will
# use later in the validation variable.

# Note that we replaced our dataset variable with the 80% sample of the dataset.
# This was an attempt to keep the rest of the code simpler and readable.


#
# Summarize Dataset
#

# Now it is time to take a look at the data.

# In this step we are going to take a look at the data a few different ways:

# 1. Dimensions of the dataset.
# 2. Types of the attributes.
# 3. Peek at the data itself.
# 4. Levels of the class attribute.
# 5. Breakdown of the instances in each class.
# 6. Statistical summary of all attributes.

# Don’t worry, each look at the data is one command. These are useful commands
# that you can use again and again on future projects.

# Dimensions of Dataset
#

# We can get a quick idea of how many instances (rows) and how many attributes
# (columns) the data contains with the dim function.

# dimensions of dataset
dim(dataset)

# Types of Attributes
#

# It is a good idea to get an idea of the types of the attributes.
# They could be doubles, integers, strings, factors and other types.

# Knowing the types is important as it will give you an idea of how to better
# summarize the data you have and the types of transforms you might need to use
# to prepare the data before you model it.

# list types for each attribute
sapply(dataset, class)

# Peek at the Data
#

# It is also always a good idea to actually eyeball your data.

# take a peek at the first 5 rows of the data
head(dataset)

# Levels of the Class
#

# The class variable is a factor. A factor is a class that has multiple class
# labels or levels. Let’s look at the levels:

# list the levels for the class
levels(dataset$Species)

# Class Distribution
#

# Let’s now take a look at the number of instances (rows) that belong to each class.
# We can view this as an absolute count and as a percentage.

# summarize the class distribution
percentage <- prop.table(table(dataset$Species)) * 100
cbind(freq=table(dataset$Species), percentage=percentage)

# Statistical Summary
#

# Now finally, we can take a look at a summary of each attribute.

# This includes the mean, the min and max values as well as some percentiles
# (25th, 50th or media and 75th e.g. values at this points if we ordered all
# the values for an attribute).

# summarize attribute distributions
summary(dataset)


#
# Visualize Dataset
#

# We now have a basic idea about the data. We need to extend that with some visualizations.

# We are going to look at two types of plots:

# 1. Univariate plots to better understand each attribute.
# 2. Multivariate plots to better understand the relationships between attributes.

# Univariate Plots
#

# We start with some univariate plots, that is, plots of each individual variable.

# It is helpful with visualization to have a way to refer to just the input attributes
# and just the output attributes. Let’s set that up and call the inputs attributes x
# and the output attribute (or class) y.

# split input and output
x <- dataset[,1:4]
y <- dataset[,5]

# Given that the input variables are numeric, we can create box and whisker plots of each.

# boxplot for each attribute on one image
par(mfrow=c(1,4))
for(i in 1:4) {
  boxplot(x[,i], main=names(iris)[i])
}

# This gives us a much clearer idea of the distribution of the input attributes:

# We can also create a barplot of the Species class variable to get a graphical
# representation of the class distribution (generally uninteresting in this case
# because they’re even).

# barplot for class breakdown
plot(y)

# Multivariate Plots
#

# Now we can look at the interactions between the variables.

# First let’s look at scatterplots of all pairs of attributes and color the points
# by class. In addition, because the scatterplots show that points for each class
# are generally separate, we can draw ellipses around them.

# scatterplot matrix
featurePlot(x=x, y=y, plot="ellipse")

# We can also look at box and whisker plots of each input variable again,
# but this time broken down into separate plots for each class. This can help
# to tease out obvious linear separations between the classes.

# box and whisker plots for each attribute
featurePlot(x=x, y=y, plot="box")

# This is useful to see that there are clearly different distributions of
# the attributes for each class value.

# Next we can get an idea of the distribution of each attribute, again like
# the box and whisker plots, broken down by class value. Sometimes histograms
# are good for this, but in this case we will use some probability density plots
# to give nice smooth lines for each distribution.

# density plots for each attribute by class value
scales <- list(x=list(relation="free"), y=list(relation="free"))
featurePlot(x=x, y=y, plot="density", scales=scales)

# Like the boxplots, we can see the difference in distribution of each attribute
# by class value. We can also see the Gaussian-like distribution (bell curve)
# of each attribute.


#
# Evaluate Some Algorithms
#

# Now it is time to create some models of the data and estimate their accuracy on unseen data.

# Here is what we are going to cover in this step:
  
# 1. Set-up the test harness to use 10-fold cross validation.
# 2. Build 5 different models to predict species from flower measurements
# 3. Select the best model.

# Test Harness
#

# We will 10-fold crossvalidation to estimate accuracy.

# This will split our dataset into 10 parts, train in 9 and test on 1 and release
# for all combinations of train-test splits. We will also repeat the process
# 3 times for each algorithm with different splits of the data into 10 groups,
# in an effort to get a more accurate estimate.

# Run algorithms using 10-fold cross validation
control <- trainControl(method="cv", number=10)
metric <- "Accuracy"

# We are using the metric of “Accuracy” to evaluate models. This is a ratio of
# the number of correctly predicted instances in divided by the total number of
# instances in the dataset multiplied by 100 to give a percentage
# (e.g. 95% accurate). We will be using the metric variable when we run build
# and evaluate each model next.

# Build Models
#

# We don’t know which algorithms would be good on this problem or what configurations
# to use. We get an idea from the plots that some of the classes are partially
# linearly separable in some dimensions, so we are expecting generally good results.

# Let’s evaluate 5 different algorithms:

# * Linear Discriminant Analysis (LDA)
# * Classification and Regression Trees (CART).
# * k-Nearest Neighbors (kNN).
# * Support Vector Machines (SVM) with a linear kernel.
# * Random Forest (RF)

# This is a good mixture of simple linear (LDA), nonlinear (CART, kNN) and complex
# nonlinear methods (SVM, RF). We reset the random number seed before reach run
# to ensure that the evaluation of each algorithm is performed using exactly
# the same data splits. It ensures the results are directly comparable.

# Let’s build our five models:

# a) linear algorithms
set.seed(7)
fit.lda <- train(Species~., data=dataset, method="lda", metric=metric, trControl=control)
# b) nonlinear algorithms
# CART
set.seed(7)
fit.cart <- train(Species~., data=dataset, method="rpart", metric=metric, trControl=control)
# kNN
set.seed(7)
fit.knn <- train(Species~., data=dataset, method="knn", metric=metric, trControl=control)
# c) advanced algorithms
# SVM
set.seed(7)
fit.svm <- train(Species~., data=dataset, method="svmRadial", metric=metric, trControl=control)
# Random Forest
set.seed(7)
fit.rf <- train(Species~., data=dataset, method="rf", metric=metric, trControl=control)

# Caret does support the configuration and tuning of the configuration of each
# model, but we are not going to cover that in this tutorial.

# Select Best Model
#

# We now have 5 models and accuracy estimations for each. We need to compare
# the models to each other and select the most accurate.

# We can report on the accuracy of each model by first creating a list of
# the created models and using the summary function.

# summarize accuracy of models
results <- resamples(list(lda=fit.lda, cart=fit.cart, knn=fit.knn, svm=fit.svm, rf=fit.rf))
summary(results)

# We can see the accuracy of each classifier and also other metrics like Kappa

# We can also create a plot of the model evaluation results and compare
# the spread and the mean accuracy of each model. There is a population of
# accuracy measures for each algorithm because each algorithm was evaluated
# 10 times (10 fold cross validation).

# compare accuracy of models
dotplot(results)

# We can see that the most accurate model in this case was LDA:

# The results for just the LDA model can be summarized.

# summarize Best Model
print(fit.lda)

# This gives a nice summary of what was used to train the model and the mean and
# standard deviation (SD) accuracy achieved, specifically 97.5% accuracy +/- 4%


#
# Make Predictions
#

# The LDA was the most accurate model. Now we want to get an idea of the accuracy
# of the model on our validation set.

# This will give us an independent final check on the accuracy of the best model.
# It is valuable to keep a validation set just in case you made a slip during such
# as overfitting to the training set or a data leak. Both will result in an overly
# optimistic result.

# We can run the LDA model directly on the validation set and summarize the results
# in a confusion matrix.

# estimate skill of LDA on the validation dataset
predictions <- predict(fit.lda, validation)
confusionMatrix(predictions, validation$Species)

# We can see that the accuracy is 100%. It was a small validation dataset (20%),
# but this result is within our expected margin of 97% +/-4% suggesting we may have
# an accurate and a reliably accurate model.

pd <- validation %>% mutate(prediction = predictions)
pd <- pd %>% mutate(correct = prediction == Species)

n <- seq_len(nrow(pd))
ggplot(data = pd) +
  geom_point(mapping = aes(x = n, y = Sepal.Length, color = Species), shape = 1) +
  geom_point(mapping = aes(x = n, y = Sepal.Width, color = Species), shape = 2) +
  geom_point(mapping = aes(x = n, y = Petal.Length, color = Species), shape = 3) +
  geom_point(mapping = aes(x = n, y = Petal.Width, color = Species), shape = 4)
