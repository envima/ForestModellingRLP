###########################################################
#                                                         #
# name: validation_mixed_polygons.R                       #
# date: 11.03.2021                                        #
# data: -> raster diverse prediction                      #
#       -> all forest inventory shapefiles                #
#                                                         #
# output: Histogram with deviation predicted & observed   #
#                                                         #
###########################################################

# 1 - set up
#-----------

setwd("D:/forest_modelling/ForestModellingRLP/")
library(rgdal)
library(raster)
library(sf)
library(gridExtra)
library(tidyverse)
library(ggplot2)

# 2 - load and filter data ####
#------------------------------

# load forest inventory data
FID = sf::read_sf("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/Exp_Shape_Wefl_UTM/wefl_UTM_BAZ_1.shp")

FID = FID[,c("FAT__ID", "Phase", "BAGRu", "proz")]
FID = na.omit(FID)
FID = FID[FID$proz < 80,]

#FID = FID[FID$Phase == c("Rei", "Dim", "Qua"),]
FID = FID[FID$BAGRu %in% c("Ei", "Fi", "Bu", "Dou", "Ki", "Lä", "Lbk", "Lbl"),]
FID = st_transform(FID, crs = 25832)
sf::write_sf(FID, "data/validation_polygons/mixed_polygons_diverse.gpkg", overwrite = TRUE)


# 3 - extract data ####
#-----------------------

# load predction and polygons
FID = rgdal::readOGR("data/validation_polygons/mixed_polygons_diverse.gpkg")
pred = raster::stack("prediction/diverse_trees_pred.grd")
aoa = raster::stack("data/aoa_diverse/aoa_diverse.grd")
aoa$AOA[aoa$AOA == 0] <- NA

predAoa = mask(pred, aoa$AOA)
# extract data
predExtr = raster::extract(predAoa, FID, df = TRUE)
rm(pred, predAoa, aoa)


# 4 - create data frame with extracted data ####
#-----------------------------------------------
FID = sf::read_sf("data/validation_polygons/mixed_polygons_diverse.gpkg")
#`%notin%` <- purrr::negate(`%in%`)

FID$ID = c(1:nrow(FID))

df = merge(predExtr, FID, by.x = 'ID', by.y = 'ID')

df_tree = data.frame(class = c(1:8), 
                     pred = c("Bu", "Dou", "Ei", "Fi", "Ki", "Lä", "Lbk", "Lbl"))


df2 = merge(df, df_tree, by.x = 'layer', by.y = 'class')
rm(df_tree)


df2 = df2[,c("FAT__ID", "Phase", "BAGRu", "proz", "pred")]
saveRDS(df2, "data/validation_polygons/mixed_polygons_diverse_extracted.RDS")

FID = sf::read_sf("data/validation_polygons/mixed_polygons_diverse.gpkg")
df = readRDS("data/validation_polygons/mixed_polygons_diverse_extracted.RDS")


# 4 - calculate derivation predicted vs observed per polygon #####
#-----------------------------------------------------------------


ID = unique(df$FAT__ID)
dfResults = data.frame(FAT_ID = NA,
                       pred = NA,
                       nrow =  c(1:length(ID)))


for (i in 1:length(ID)) {
  
  p = df[df$FAT__ID == ID[i],]
  tree = as.character(p$BAGRu[1])
  predProz = nrow(p[p$pred == tree,])/nrow(p)
  dfResults$FAT_ID[i] = ID[i]
  dfResults$pred[i] = predProz
  
}

df2 = merge(dfResults, FID, by.x = 'FAT_ID', by.y = 'FAT__ID', all.y = FALSE)
write_sf(df2, "valid_diverse.gpkg")


# 5 - plot and save Histogram #####
#--------------------------

df = sf::read_sf("data/validation_polygons/all_diverse_polygons_finished.gpkg")


for (BA in c("Bu", "Dou", "Ei", "Fi", "Ki", "Lä", "Lbk", "Lbl", "all")) {
  
  if (BA == "all") {
    df2 = df 
  } else {
    df2 = df[df$BAGRu == BA,] 
  }
    
  H = NULL
  for (i in 1:nrow(df2)) {
    pro = df2$pred[i]*100 - df2$proz[i]
    H = append(H, pro)
  }
  
  p = ggplot()+aes(H)+
    stat_bin(binwidth=10, fill="chartreuse3", color="#e9ecef") +  
    stat_bin(binwidth=10, geom="text", aes(label=..count..), vjust=-1.5, size = 4) +
    expand_limits(y= c(NA, max(hist(H)$counts)*1.2)) +
    ylab("number of polygons") +
    xlab("deviation")
  
  ggsave(filename = paste0("data/validation_polygons/images/diverse_val_", BA, ".png"),
         plot = p, 
         width = 10,
         limitsize = FALSE,
         device = png())
  
  
}
rm(df2, H, BA, i, pro, p)













