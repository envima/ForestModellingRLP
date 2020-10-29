# name:   validation.R
# date:   28.10.2020
# data:   - prediction Raster
#         - Shapefiles with true information
# output: caret::confusionMatrix


# 1 - set up 
#-----------

require(sf)
require(raster)
require(caret)

# 2 - load shapefiles and prediction raster ####
#-----------------------------------------------

# IDs of training Polygons
training <- read.csv("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/validation/RLP_extration_protocoll.csv")
# Forsteinrichtungsdaten
all_data <- sf::read_sf("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/Exp_Shape_Wefl_UTM/Trainingsgebiete_RLP/Etb_Qua_Dim_Rei_WGS84.shp")

# select all IDs that are not part of trainings data
`%not_in%` <- purrr::negate(`%in%`)
shapes <- all_data[all_data$FAT__ID %not_in% training$FAT__ID,]

# cleaning
rm(all_data, training, '%not_in%')
shapes = subset(shapes, select = c(FAT__ID, BA_Nr,BAGRu, BAGrp, proz,
                                   Phase, geometry))

# prediction raster
pred <- raster::raster("prediction/diverse_trees_pred.grd")
#pred <- raster::raster("prediction/main_trees_pred.grd")

# same crs for both data records
shapes <- sf::st_transform(shapes, crs(pred))


# 3 - confusion matrix ####
#--------------------------

# extract predicted values for each polygon
pred_extr <- raster::extract(pred, shapes)

# to data frame
pred_extr <- as.data.frame(do.call(rbind,pred_extr))


# tree species
BA <- data.frame(BA = c("Bu", "Dou", "Ei", "Fi", "Ki", "Lä", "Lbk", "Lbl", "Ta"),
                 NO = c(1:9))
shapes <- merge(BA, shapes, by.x = "BA", by.y = "BAGRu")
rm(BA)

# merge
shapes <- as.data.frame(shapes)
pred_extr <- cbind(shapes, pred_extr)


# one dataframe with two columns; true and predicted
names <- colnames(pred_extr)
names <- names[9:76]
val <- NULL
for (i in names){
v <- data.frame(SHP = pred_extr$NO, PRED = pred_extr[i])
colnames(v)[2] <- "PRED"
val <- rbind(val, v)
}
rm(v,i,names)


# confusion Matrix
caret::confusionMatrix(data = as.factor(val$PRED), reference = as.factor(val$SHP))


