---
output:
  pdf_document: default
  html_document: default
---
```{r}
# Import library
library(readxl)
library(dplyr)
library(ggplot2)
library(cowplot)
# Random forest library
library(randomForest)
library(psych)
library(keras)
# Lasso
library(glmnet)
library(caret)
library(boot)
library(car)
library(scales)
library(glm2)

```

```{r}
#import data
forestfires <- read.csv("C:\\Users\\54088\\OneDrive\\桌面\\SW\\S5 2023\\STAT 4893W\\Second Project\\forestfires.csv")

# Rearrange the variables
forestfires <- forestfires %>% 
  mutate(month = case_when(month %in% "jan" ~ 1,
                           month %in% "feb" ~ 2, 
                           month %in% "mar" ~ 3,
                           month %in% "apr" ~ 4,
                           month %in% "may" ~ 5,
                           month %in% "jun" ~ 6,
                           month %in% "jul" ~ 7,
                           month %in% "aug" ~ 8,
                           month %in% "sep" ~ 9,
                           month %in% "oct" ~ 10,
                           month %in% "nov" ~ 11,
                           month %in% "dec" ~ 12))

forestfires <- forestfires %>%
  mutate(day = case_when(day %in% "mon" ~ 1, 
                         day %in% "tue" ~ 2,
                         day %in% "wed" ~ 3,
                         day %in% "thu" ~ 4,
                         day %in% "fri" ~ 5,
                         day %in% "sat" ~ 6,
                         day %in% "sun" ~ 7))

forestfires$RH <- as.numeric(forestfires$RH)
```

```{r}
EDA_forest <- forestfires
par(mfrow = c(1, 9))

# X
# Plot for X
ggplot(EDA_forest, aes(x = X)) +
  geom_bar(fill = "lightblue", color = "black") +
  theme_minimal() +
  ggtitle("Distribution of X")

# Y
# Plot for Y
ggplot(EDA_forest, aes(x = Y)) +
  geom_bar(fill = "lightblue", color = "black") +
  theme_minimal() +
  ggtitle("Distribution of Y")

# FFMC
ggplot(EDA_forest, aes(x = FFMC)) +
  geom_histogram(binwidth = 2, fill = "lightblue", color = "black") +
  theme_minimal() +
  ggtitle("Distribution of FFMC")

# DMC
ggplot(EDA_forest, aes(x = DMC)) +
  geom_histogram(binwidth = 10, fill = "lightblue", color = "black") +
  theme_minimal() +
  ggtitle("Distribution of DMC")

# DC
ggplot(EDA_forest, aes(x = DC)) +
  geom_histogram(binwidth = 25, fill = "lightblue", color = "black") +
  theme_minimal() +
  ggtitle("Distribution of DC")

# ISI
ggplot(EDA_forest, aes(x = ISI)) +
  geom_histogram(binwidth = 2, fill = "lightblue", color = "black") +
  theme_minimal() +
  ggtitle("Distribution of ISI")

# temp
ggplot(EDA_forest, aes(x = temp)) +
  geom_histogram(binwidth = 1, fill = "lightblue", color = "black") +
  theme_minimal() +
  ggtitle("Distribution of temp")

# RH
ggplot(EDA_forest, aes(x = RH)) +
  geom_histogram(binwidth = 1, fill = "lightblue", color = "black") +
  theme_minimal() +
  ggtitle("Distribution of RH")

# wind
ggplot(EDA_forest, aes(x = wind)) +
  geom_histogram(binwidth = 0.5, fill = "lightblue", color = "black") +
  theme_minimal() +
  ggtitle("Distribution of wind")

# rain
ggplot(EDA_forest, aes(x = rain)) +
  geom_histogram(binwidth = 0.5, fill = "lightblue", color = "black") +
  theme_minimal() +
  ggtitle("Distribution of rain")

# area
ggplot(EDA_forest, aes(x = area)) +
  geom_histogram(binwidth = 100, fill = "lightblue", color = "black") +
  theme_minimal() +
  ggtitle("Distribution of area")
```


```{r}
# EDA for month
month1 <- sum(forestfires$month == 1)
month2 <- sum(forestfires$month == 2)
month3 <- sum(forestfires$month == 3)
month4 <- sum(forestfires$month == 4)
month5 <- sum(forestfires$month == 5)
month6 <- sum(forestfires$month == 6)
month7 <- sum(forestfires$month == 7)
month8 <- sum(forestfires$month == 8)
month9 <- sum(forestfires$month == 9)
month10 <- sum(forestfires$month == 10)
month11 <- sum(forestfires$month == 11)
month12 <- sum(forestfires$month == 12)

colors <- c("#F8766D", "#DE8C00", "#B79F00", "#7CAE00", "#00BA38", "#00C08B", "#00BFC4","#00B4F0", "#619CFF", "#C77CFF", "#F564E3", "#FF64B0")
barplot(table(forestfires$month), col = colors, main = "Countplot for the days in the month", names.arg = c("jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"))

colors <- c("#F8766D", "#C49A00", "#53B400", "#00C094", "#00B6EB", "#A58AFF", "#FB61D7")
barplot(table(forestfires$day), col = colors, main = "Count plot for the days in the week", names.arg = c("mon", "tue", "wed", "thu", "fri", "sat", "sun"))
```

```{r}
# Zero-inflated poisson model
zim_fires <- forestfires
zim_fires$area <- round(zim_fires$area)

library(pscl)
set.seed(4893)
nr = nrow(zim_fires)
train_indices = sample(nr, nr*0.7)
train_zim <- zim_fires[train_indices, ]
test_zim <- zim_fires[-train_indices, ]

# The former part specifies the count model formula implies the predictive variable affect the count model and the latter part after | is the zero-inflated model, implies what predictive variable affect the probability of getting a zero. 
model_zim <- zeroinfl(area ~ .|., data = train_zim, family = "negbin")
summary(model_zim)

# Large pearson residual indicates poor fit or outliers.
# For the non-zero counts of the area variable. Every predictive variables have strong association with the area. But, when it comes to the probability of the zeros, the increase of variables "day", "DC", "ISI", the probability of area being zero increase.   

#(poisson with log link): meaning the count part is modeled using a Poisson distribution. log link helps with making sure that the result is positive integer.

#(binomial with logit link): Binomial (0 or 1). The logit translates the linear combination of predictors into a probability between 0 and 1.

# The log likelihood shows how good the model fits the data, the higher the number is, the greater the model fits the data.

predict_zim <- predict(model_zim, newdata = test_zim, type = "count")

#MAE
mae_zim <- mean(abs(predict_zim - test_zim$area))
mae_zim


#MAD 
mad_zim <- median(abs(predict_zim - mean(test_zim$area)))
mad_zim

# Accurancy
actual_zero <- ifelse(test_zim$area == 0, 1, 0)
predicted <- ifelse(predict_zim > 0.5, 1, 0)
table(actual_zero, predicted)
mean(predicted!=test_zim$area)

```

```{r}
# hurdle model
hurdle_fires <- forestfires
hurdle_fires$area <- round(hurdle_fires$area)

set.seed(4893)
nr = nrow(hurdle_fires)
train_indices = sample(nr, nr*0.7)
train_hurdle <- hurdle_fires[train_indices, ]
test_hurdle <- hurdle_fires[-train_indices, ]

model_hurdle <- hurdle(area ~ .|., data = train_hurdle, family = "negbin")
summary(model_hurdle)

predict_hurdle <- predict(model_hurdle, newdata = test_hurdle, type = "zero")
#MAE
mae_hurdle <- mean(abs(predict_hurdle - test_hurdle$area))

#MAD 
mad_hurdle <- median(abs(predict_hurdle - mean(test_hurdle$area)))

# Accurancy
actual_zero <- ifelse(test_hurdle$area == 0, 1, 0)
predicted <- ifelse(predict_hurdle > 0.5, 1, 0)
table(actual_zero, predicted)
(62+9)/(80+62+9+5)
mean(predicted!=test_hurdle$area)

# Compared 
data.frame(
  cbind(mae_zim, mae_hurdle),
  cbind(mad_zim, mad_hurdle)
)
mae_zim

```

```{r}
# Monte Carlo simulation 
# We want to do variables selection, for count model, since we need the variables be general, we exclude the X, Y, month, day because it can vary from place to place. We rank in RH, DMC, DC, temp, FFMC, ISI, wind and rain in order. 
# For zero-hurdle model, wind is the only model that help us.

# select the top three important variables
hurdle_model <- hurdle(area ~ FFMC + DMC + DC + ISI + temp + RH + wind + rain|wind, data = train_hurdle, family = "negbin")
summary(hurdle_model)
# Remove some variables p-value larger than 2^e-10 <- DC and rain

# simulation preprocess
set.seed(4052)
sim_FFMC <- rnorm(n = 1000, mean = mean(hurdle_fires$FFMC), sd = sd(hurdle_fires$FFMC))
sim_DMC <- rnorm(n = 1000, mean = mean(hurdle_fires$DMC), sd = sd(hurdle_fires$DMC))
sim_ISI <- rnorm(n = 1000, mean = mean(hurdle_fires$ISI), sd = sd(hurdle_fires$ISI))
sim_temp <- rnorm(n = 1000, mean = mean(hurdle_fires$temp), sd = sd(hurdle_fires$temp))
sim_RH <- rnorm(n = 1000, mean = mean(hurdle_fires$RH), sd = sd(hurdle_fires$RH))
sim_wind <- rnorm(n = 1000, mean = mean(hurdle_fires$wind), sd = sd(hurdle_fires$wind))


while(any(sim_FFMC < 18)){
  sim_FFMC[sim_FFMC < 18] <- rnorm(sum(sim_FFMC < 18), mean = mean(hurdle_fires$FFMC), sd = sd(hurdle_fires$FFMC))
}
while(any(sim_DMC < 1)){
  sim_DMC[sim_DMC < 1] <- rnorm(sum(sim_DMC < 1), mean = mean(hurdle_fires$DMC), sd = sd(hurdle_fires$DMC))
}
while(any(sim_ISI < 0)){
  sim_ISI[sim_ISI < 0] <- rnorm(sum(sim_ISI < 0), mean = mean(hurdle_fires$ISI), sd = sd(hurdle_fires$ISI))
}
while(any(sim_temp < 2)){
  sim_temp[sim_temp < 2] <- rnorm(sum(sim_temp < 2), mean = mean(hurdle_fires$temp), sd = sd(hurdle_fires$temp))
}
while(any(sim_RH < 15)){
  sim_RH[sim_RH < 15] <- rnorm(sum(sim_RH < 15), mean = mean(hurdle_fires$RH), sd = sd(hurdle_fires$RH))
}
while(any(sim_wind < 0)){
  sim_wind[sim_wind < 0] <- rnorm(sum(sim_wind < 0), mean = mean(hurdle_fires$wind), sd = sd(hurdle_fires$wind))
}

sim_wind <- round(sim_wind, digits = 1)
sim_RH <- round(sim_RH, digits = 0)
sim_FFMC <- round(sim_FFMC, digits = 1)

sim_data <- data.frame(FFMC = sim_FFMC, DMC = sim_DMC, ISI = sim_ISI, temp = sim_temp, RH = sim_RH, wind = sim_wind)


# Simulation
# training and testing set
model_hurdle <- hurdle(area ~ FFMC + DMC + ISI + temp + RH + wind|wind, data = train_hurdle, family = "negbin")
summary(model_hurdle)

predict_hurdle <- predict(model_hurdle, newdata = test_hurdle, type = "count")

# simulation set
hurdle_model <- hurdle(area ~ FFMC + DMC + ISI + temp + RH + wind|wind, data = train_hurdle, family = "negbin")
summary(hurdle_model)
sim_predictions <- predict(hurdle_model, newdata = sim_data, type = "count")

# Compare.
hist(predict_hurdle)
hist(sim_predictions)
hist(forestfires$area)
# I like the result because the plot looks like the real world situation. 

```

```{r}
# 4052 single decision tree
library(MASS)
library(tree)
dat = forestfires

nr = nrow(dat)
train_idr = sample(nr, nr*0.7)
trainr = dat[train_idr,]
valr = dat[-train_idr,]

m1r = tree(area ~ ., trainr)
summary(m1r)
plot(m1r)
text(m1r, pretty = 0)

pred1r = predict(m1r, valr)
# Validation MSE
mean((pred1r - valr$area) ^ 2)

# find the optimal size to prune the tree
# Regression tree model
set.seed(4052)
# Cross-validation
m2r = cv.tree(m1r)

plot(m2r$size, m2r$dev, type = "b", xlab = "tree size", ylab = "dev")

m3r = prune.tree(m1r, best = 3)
plot(m3r)
text(m3r, pretty = 0)

pred3r = predict(m3r, valr)
mean((pred3r - valr$area) ^ 2)


# RF and Bagging 
# random forest model
m4r = randomForest(area ~ ., data = trainr, mtry = 3, importance = TRUE)

pred4r = predict(m4r, valr)
mean((pred4r - valr$area) ^ 2)
importance(m4r)
varImpPlot(m4r)

m4r
# Gradient Boosting 
library(gbm)
m6r = gbm(area ~ ., data = trainr, distribution = "gaussian", n.trees = 5000, interaction.depth = 1, shrinkage = 0.1)

pred6r = predict(m6r, valr, n.trees = 5000)
mean((pred6r - valr$area) ^ 2)

summary(m6r)

# MAE
mae_rf_lecture <- mean(abs(pred4r - valr))
mae_rf_lecture

# MAD for the test value
mad_rf_lecture <- mean(abs(pred4r - mean(pred4r)))
mad_rf_lecture

```


```{r}
# Random Forest
rf_fires <- forestfires

# Separate the data
set.seed(4893)

rf_fires = rf_fires[5:13]
nr = nrow(rf_fires)
train_indices = sample(nr, nr*0.7)
train_rf <- rf_fires[train_indices, ]
test_rf <- rf_fires[-train_indices, ]


# Use 10-fold cross-validation to find the optimal trees for the model
# Define the control using 10-fold cross-validation
train_control <- trainControl(method = "cv", number = 10)


# Train the model using the caret package to find the optimal mtry and ntree
# Note: the tuneGrid parameter can be used to specify custom values for mtry and ntree
model_rf_train <- train(area ~ ., data = train_rf, method = "rf",
               trControl = train_control,
               tuneLength = 20) 
# tuneLength is the number of different values to try

# Print the results
model_rf_train$finalModel$mtry
model_rf_train$finalModel$ntree

# Building model
# The variance of explained is negative
# mtry = predictive variables / 3 = 13 / 3 = around 4
model_rf <- randomForest(area ~ ., data = train_rf, ntree = 500, mtry = 3, importance = TRUE)
prediction_rf <- predict(model_rf, test_rf)
importance(model_rf)
varImpPlot(model_rf)

model_rf
# MAE
mae_rf <- mean(abs(prediction_rf - valr))
mae_rf

# MAD
mad_rf <- mean(abs(prediction_rf - mean(prediction_rf)))
mad_rf
```
