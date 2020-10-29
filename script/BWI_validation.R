###########################################################
# name: BWI_validation.R                                  #
# date: 19.10.2020                                        #
# data: - BWI shapefiles of 10 m radius for each corner   #
#       - prediction raster                               #
#         -> classes:                                     #
#             1 Buche                                     #
#             2 Douglasie                                 #
#             3 Eiche                                     #
#             4 Fichte                                    #
#             5 Kiefer                                    #
#             6 Laerche                                   #
#             7 kurlebige Laubbaeume                      #
#             8 langlebige Laubbaeume                     #
#             9 Tannen                                    #
###########################################################



# 1 - set up
#-----------

library(sf)
library(raster)
library(caret)

# 2 - load prediction and BWI data ####
#--------------------------------------

BWI <- sf::read_sf("data/BWI/BWI_validation.shp")
pred <- raster::raster("data/prediction/main_trees_pred.grd")
BWI <- sf::st_transform(BWI, crs(pred))

aoa = raster::raster("data/aoa_main/aoa_main.grd", 2)

# 3 - confusion matrix ####
#--------------------------
# extract predicted values for each polygon of BWI
pred_extr <- raster::extract(pred, BWI, df = TRUE)

BWI$ID = seq(nrow(BWI))

pred_extr = merge(st_drop_geometry(BWI), pred_extr, by = "ID")
pred_extr = na.omit(pred_extr)

valid = data.frame(BWI = pred_extr$Pred_No, pred = pred_extr$layer)

validConf = valid[valid$BWI %in% seq(5),]
confusionMatrix(table(validConf))
pred_extr$aoa = aoa_extr$AOA


# extract aoa

aoa_extr = raster::extract(aoa, BWI, df = TRUE)
aoa_extr = merge(st_drop_geometry(BWI), aoa_extr, by = "ID")
aoa_extr = na.omit(aoa_extr)


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


