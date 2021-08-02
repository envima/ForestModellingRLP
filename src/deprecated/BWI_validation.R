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
BWI$ID = seq(nrow(BWI))

aoa = raster::raster("data/aoa_main/aoa_main.grd", 2)

# 3 - confusion matrix ####
#--------------------------
# extract predicted values for each polygon of BWI
pred_extr <- raster::extract(pred, BWI, df = TRUE)


pred_extr = merge(st_drop_geometry(BWI), pred_extr, by = "ID")
pred_extr = na.omit(pred_extr)

valid = data.frame(BWI = pred_extr$Pred_No, pred = pred_extr$layer)

validConf = valid[valid$BWI %in% seq(5),]
confusionMatrix(table(validConf))



# extract aoa

aoa_extr = raster::extract(aoa, BWI, df = TRUE)
aoa_extr = merge(st_drop_geometry(BWI), aoa_extr, by = "ID")
aoa_extr = na.omit(aoa_extr)
valid$aoa = aoa_extr$AOA

validConf = valid[valid$BWI %in% seq(5),]
# confusion with all areas
confusionMatrix(table(validConf[,1:2]))
# confusion within AOA
confusionMatrix(table(validConf[validConf$aoa == 1,1:2]))
# confusion outside of AOA
confusionMatrix(table(validConf[validConf$aoa == 0,1:2]))

#---------------------------------------------

# same for diverse



pred <- raster::raster("data/prediction/diverse_trees_pred.grd")
aoa = raster::raster("data/aoa_diverse/aoa_diverse.grd", 2)





pred_extr <- raster::extract(pred, BWI, df = TRUE)


pred_extr = merge(st_drop_geometry(BWI), pred_extr, by = "ID")
pred_extr = na.omit(pred_extr)

valid = data.frame(BWI = pred_extr$Pred_No, pred = pred_extr$layer)

# extract aoa

aoa_extr = raster::extract(aoa, BWI, df = TRUE)
aoa_extr = merge(st_drop_geometry(BWI), aoa_extr, by = "ID")
aoa_extr = na.omit(aoa_extr)
valid$aoa = aoa_extr$AOA

validConf = valid[valid$BWI %in% seq(8),]
# confusion with all areas
confusionMatrix(table(validConf[,1:2]))
# confusion within AOA
confusionMatrix(table(validConf[validConf$aoa == 1,1:2]))
# confusion outside of AOA
confusionMatrix(table(validConf[validConf$aoa == 0,1:2]))









