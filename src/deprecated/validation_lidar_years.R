# name: validation_lidar_years.R
# date: 28.04.2021
# data: - lidar recording dates as polygons
#       - forest inventory polygons
#       - extracted data
#       - models



# 1 - set up
#-----------

library(sf)
library(tidyverse)
library(caret)
`%not_in%` <- purrr::negate(`%in%`)


# 2 - load data
#--------------

# create one polygon for each year

#lidar = sf::read_sf("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/Daten/Lidar/aktualitaet_laserbefliegung_21082018.shp")
#lidar = lidar %>% 
#  group_by(JahrDerBef) %>%
#  summarise(geometry = sf::st_union(geometry)) %>%
#  ungroup()

#sf::write_sf(lidar, "boundaries_lidar_years.gpkg")

#load lidar recording boundaries
lidar = read_sf("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/Daten/Lidar/boundaries_lidar_years.gpkg")

# relevant class information from original polygons
polygons = st_read("data/Trainingsgebiete_RLP/Etb_Qua_Dim_Rei_WGS84.gpkg")
polygons = sf::st_transform(polygons, st_crs(lidar))
polygons = polygons[,c("FAT__ID", "Phase", "BAGRu")]
polygons <- sf::st_buffer(polygons, byid=TRUE, dist=0)

# 3 - validation for each year
#-----------------------------

for(y in lidar$JahrDerBef) {
year = lidar[lidar$JahrDerBef == y,]
year_polygons = st_intersection(year, polygons)


# attach relevant class information to full extraction set
# format properly
rlp_extract = readRDS("data/model_training_data/RLP_extract.RDS")
rlp_extract = merge(rlp_extract, year_polygons, by = "FAT__ID")
rlp_extract$surface_intensity_mean = NULL
rlp_extract$ID = NULL
rlp_extract$Quality = paste0(rlp_extract$BAGRu, "_", rlp_extract$Phase)



# validation for each model

models = c("meta_classes_main_trees", "meta_classes_diverse")

for(m in models){
  meta = list()
  training_set = readRDS(paste0("data/model_training_data/", m,".RDS"))
  
  meta$'Model' = m
  meta$'Number of training polygons' = length(unique(training_set$FAT__ID))
  meta$'Number of training pixel per class' = as.list(table(training_set$BAGRu))
  
  rlp_extract_sub = rlp_extract %>% filter(BAGRu %in% unique(training_set$BAGRu)) %>% filter(FAT__ID %not_in% training_set$FAT__ID)
  rlp_extract_sub = na.omit(rlp_extract_sub)
  
  meta$'Number of validation polygons' = length(unique(rlp_extract_sub$FAT__ID))
  meta$'Number of validation pixel per class' = as.list(table(rlp_extract_sub$BAGRu))
  
  
  # load model
  mod = readRDS(paste0("data/models/", m,"_ffs.RDS"))
  valid = stats::predict(object = mod, newdata = rlp_extract_sub)
  
  val_df = data.frame(FAT__ID = rlp_extract_sub$FAT__ID,
                      Observed = rlp_extract_sub$BAGRu, 
                      Predicted = valid)
  # different levels
  observed <- val_df$Observed 
  predicted <- val_df$Predicted 
  
  u <- union(predicted, observed)
  t <- table(factor(predicted, u), factor(observed, u))
  val_cm = confusionMatrix(t)
  
  
  # output
  
  saveRDS(val_df, paste0("data/validation_lidar/", m, "_", y, "_validation_df.RDS"))
  saveRDS(val_cm, paste0("data/validation_lidar/", m, "_", y, "_confusionmatrix.RDS"))
  yaml::write_yaml(yaml::as.yaml(meta), file = paste0("data/validation_lidar/", m, "_", y, "_meta.yaml"))
}

}


