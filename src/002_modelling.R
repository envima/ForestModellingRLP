#' sub control script for data preparation
#'
#'
#' @description Use this script for controlling the processing.
#'
#' @author [name], [email@com]
#'

library(envimaR)
library(rprojroot)
root_folder = find_rstudio_root_file()

source(file.path(root_folder, "src/functions/000_setup.R"))


# 1. extraction
# 2. balancing
# 4. 


# 1 - extraction ####
#-------------------#

# 1.1 - load sentinel data ####
#-----------------------------#

summer <- terra::rast(file.path(envrmt$summer, "summer.tif"))
winter <- terra::rast(file.path(envrmt$winter, "winter.tif"))
lidar <- terra::rast(file.path(envrmt$lidar, "LIDAR.tif"))
# stack all
RLP <- terra::rast(list(summer, winter, lidar))

# 1.2 - load forest inventory data ####
#-------------------------------------#

pol = sf::read_sf(file.path(envrmt$FID, "Trainingsgebiete_RLP.gpkg"))
#pol = st_transform(rlp_forest, crs = 25832)


# 1.3 - extract ####
#------------------#

rlpExtr = extraction(rasterStack = RLP, 
                     pol = pol, 
                     bufferSize = -20, 
                     idColName = "FAT__ID")


saveRDS(rlpExtr, file.path(envrmt$model_training_data, "RLP_extract.RDS"))


# 2 - balancing ####
#-----------------#

# input
extr = readRDS(file.path(envrmt$model_training_data, "RLP_extract.RDS"))
polygons = st_read(file.path(envrmt$FID, "Trainingsgebiete_RLP.gpkg")) %>% st_drop_geometry()
polygons = polygons[,c("FAT__ID", "Phase", "BAGRu")]
extr = merge(extr, polygons, by = "FAT__ID")
rm(polygons)

# 2.1 balance main model ####
#---------------------------#

main = balancing(extr = extr,
                    response = "BAGRu",
                    class = c("Fi", "Ei", "Ki", "Bu", "Dou"))

saveRDS(main, file.path(envrmt$model_training_data, "main.RDS"))

# 2.2 balance diverse model ####
#------------------------------#

diverse = balancing(extr = extr,
                    response = "BAGRu",
                    class = c("Fi", "Ei", "Ki", "Bu", "Dou", "Lbk", "Lbl", "Lä"))

saveRDS(diverse, file.path(envrmt$model_training_data,"diverse.RDS"))

# 2.3 balance successional stages ####
#------------------------------------#

data = extr %>% filter(Phase != "Etb")
data$Quality = paste0(data$BAGRu, "_", data$Phase)


for (i in unique(data$BAGRu)) {
  df = data %>% filter(BAGRu == i)
  quality = balancing(extr = df,
                      response = "Quality",
                      class = unique(df$Quality))
  
  saveRDS(quality, file.path(envrmt$model_training_data, paste0(i, ".RDS")))
}


# 3 - modelling ####
#------------------#

# 3.1 - tree species ####
#-----------------------#



modelling(predResp = ,
          responseColName = ,
          responseType = ,
          predictorsColNo = ,
          spacevar = ,
          ncores = 10)

# 3.2 - successional stages ####
#------------------------------#

# 4 - prediction & AOA ####
#-------------------------#


