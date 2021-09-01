#' sub control script for modelling
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

# Content
# 1. extraction
# 2. balancing
# 3. modelling
# 4. prediction & AOA


# 1 - extraction ####
#-------------------#

# 1.1 - load sentinel data ####
#-----------------------------#

summer <- terra::rast(file.path(envrmt$summer, "summer.tif"))
winter <- terra::rast(file.path(envrmt$winter, "winter.tif"))
# stack all
RLP <- terra::rast(list(summer, winter))
rm(summer,winter)
# 1.2 - load forest inventory data ####
#-------------------------------------#

pol = sf::read_sf(file.path(envrmt$FID, "Trainingsgebiete_RLP.gpkg"))
#pol = st_transform(rlp_forest, crs = 25832)


# 1.3 - extract ####
#------------------#
# Access RSDB
#userpwd <- "user:password" # use this account (if not loaded from file)
fileName <- file.path(envrmt$lidar, "remote_sensing_userpwd.txt") # optional file in home directory content: user:password
userpwd <- readChar(fileName, file.info(fileName)$size) # optional read account from file
# open remote sensing database
remotesensing <- RemoteSensing$new("http://192.168.191.183:8081", userpwd) # remote server
# get one rasterdb
rasterdb <- remotesensing$rasterdb("RLP_forest_mask_20m_i4")


rlpExtr = extraction(rasterStack = RLP, 
                     pol = pol, 
                     bufferSize = -20, 
                     idColName = "FAT__ID")


saveRDS(rlpExtr, file.path(envrmt$model_training_data, "extract.RDS"))


# 2 - balancing ####
#-----------------#
polygons = sf::read_sf(file.path(envrmt$FID, "Trainingsgebiete_RLP.gpkg")) %>% st_drop_geometry()
# relevant class information from original polygons
polygons = polygons[,c("FAT__ID", "Phase", "BAGRu")]
# attach relevant class information to full extraction set
extract = readRDS(file.path(envrmt$model_training_data, "extract.RDS"))

# format properly
extract = merge(extract, polygons, by = "FAT__ID")
rm(polygons)
extract$surface_intensity_mean = NULL
extract$ID = NULL

extract$Quality = paste0(extract$BAGRu, "_", extract$Phase)


# 2.1 balance main model ####
#---------------------------#

main = balancing(pred_resp = extract,
                 response = "BAGRu",
                 class = c("Fi", "Ei", "Ki", "Bu", "Dou"),
                 idCol = "FAT__ID")

##control
head(main)
as.data.frame(table(factor(main$FAT__ID)))
ddply(main,~BAGRu,summarise,number_of_distinct_locations=n_distinct(FAT__ID))


##save
saveRDS(main, file.path(envrmt$model_training_data, "main.RDS"))

# 2.2 balance diverse model ####
#------------------------------#

diverse = balancing(pred_resp = extract,
                    response = "BAGRu",
                    class = c("Fi", "Ei", "Ki", "Bu", "Dou", "Lbk", "Lbl", "Lä"),
                    idCol = "FAT__ID")

saveRDS(diverse, file.path(envrmt$model_training_data,"diverse.RDS"))

##control
head(diverse)
as.data.frame(table(factor(diverse$FAT__ID)))
ddply(diverse,~BAGRu,summarise,number_of_distinct_locations=n_distinct(FAT__ID))

# 2.3 balance successional stages ####
#------------------------------------#

data = extract %>% filter(Phase != "Etb")


for (i in unique(data$BAGRu)) {
  df = data %>% filter(BAGRu == i)
  quality = balancing(pred_resp = df,
                      response = "Quality",
                      class = unique(df$Quality),
                      idCol = "FAT__ID")
  # control
  as.data.frame(table(factor(quality$FAT__ID)))
  ddply(quality,~BAGRu,summarise,number_of_distinct_locations=n_distinct(FAT__ID))
  
  saveRDS(quality, file.path(envrmt$model_training_data, paste0("quality_", i, ".RDS")))
}


# 3 - modelling ####
#------------------#

# 3.1 - tree species ####
#-----------------------#

## choose model response
response_type = c("main", "diverse")

for (i in response_type) {
  # load modelling data
  predResp = readRDS(file.path(envrmt$model_training_data, paste0(i, ".RDS")))
  
  
  mod = modelling(predResp,
                  responseColName = "BAGRu",
                  responseType = i,
                  predictorsColNo = 2:131,
                  spacevar = "FAT__ID",
                  ncores = 10)
  
  saveRDS(mod, file.path(envrmt$models, paste0(i, "_ffs.RDS")))
} # end for loop

# 3.2 - successional stages ####
#------------------------------#


lstQuality = list.files(file.path(envrmt$model_training_data), pattern = "quality")

for (i in lstQuality) {
  # load modelling data
  predResp = readRDS(file.path(envrmt$model_training_data, i))
  responseType = gsub("quality_", "", i)
  responseType = gsub(".RDS", "", responseType)
  
  mod = modelling(predResp,
                  responseColName = "BAGRu",
                  responseType = responseType,
                  predictorsColNo = 2:131,
                  spacevar = "FAT__ID",
                  ncores = 10)
  
  saveRDS(mod, file.path(envrmt$models, paste0("quality_", responseType, "_ffs.RDS")))
} # end for loop

# 4 - prediction & AOA ####
#-------------------------#


prediction_aoa(lstSpecies = c("main", "diverse"), 
               lstQuality = "quality")


