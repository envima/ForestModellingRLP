# name: BWI_validation.R
# date: 19.10.2020
# data: 


# 1 - set up
#-----------

library(sf)
library(raster)
library(caret)

# 2 - load prediction and BWI data ####
#--------------------------------------

BWI <- sf::read_sf("data/BWI/BWI_validation.shp")
pred <- raster::raster("prediction/diverse_trees_pred.grd")
BWI <- sf::st_transform(BWI, crs(pred))


# 3 - confusion matrix ####
#--------------------------
# extract predicted values for each polygon of BWI
pred_extr <- raster::extract(pred, BWI)
pred_extr <- as.data.frame(do.call(rbind,pred_extr))

# Dataframe for each true pixel one predicted pixel 
BWI <- as.data.frame(BWI)
pred_extr <- cbind(BWI, pred_extr)

val <- na.omit(rbind (data.frame(BWI = pred_extr$Pred_No, PRED = pred_extr$V1),
                      data.frame(BWI = pred_extr$Pred_No, PRED = pred_extr$V2),
                      data.frame(BWI = pred_extr$Pred_No, PRED = pred_extr$V3),
                      data.frame(BWI = pred_extr$Pred_No, PRED = pred_extr$V4)
                      )
               )

# confusion Matrix
caret::confusionMatrix(data = as.factor(val$PRED), reference = as.factor(val$BWI))

