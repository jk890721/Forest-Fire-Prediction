## Forest Fire Project
#### In this project, we will train and test the models using different models, including Random Forest, Zero-inflated model, and hurdle model. After finding the best model using MAE and MAD, we use Monte Carlo simulation to see how the result goes.  

## Dependencies 
- readxl
- dplyr
- ggplot2
- cowplot
- randomForest
- psych
- keras
- glmnet
- caret
- boot
- car
- scales
- glm2



## Features
####  The dataset was downloaded from Yahoo Finance.
- X - x-axis spatial coordinate within the Montesinho park map: 1 to 9
- Y - y-axis spatial coordinate within the Montesinho park map: 2 to 9
- month - month of the year: 'jan' to 'dec'
- day - day of the week: 'mon' to 'sun'
- FFMC - Fine Fuel Moisture Code index from the FWI system: 18.7 to 96.20
- DMC - Duff Moisture index from the FWI system: 1.1 to 291.3
- DC - Drought Code index from the FWI system: 7.9 to 860.6
- ISI - Initial Spread Index from the FWI system: 0.0 to 56.10
- temp - Temperature in Celsius degrees: 2.2 to 33.30
- RH - Relative Humidity in %: 15.0 to 100
- wind - Wind Speed in km/h: 0.40 to 9.40
- rain - outside rain in mm/m2 : 0.0 to 6.4
- area - the burned area of the forest (in ha): 0.00 to 1090.84




