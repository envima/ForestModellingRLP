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




#data: sentinel tiles; source: https://scihub.copernicus.eu/dhus/#/home
#                              winter: Sentinel-2B. Tiles: 2019/02/27: T31UGR, T32ULA, T32ULB, T32ULV, T32UMB
#                                                         2019/02/24: T32UMA, T32UMV
#                              summer: Sentinel-2B. Tiles: 2019/06/27: T31UGR, T32ULA, T32ULB, T32ULV, T32UMB
#                                                         2019/06/24: T32UMV, T32UMA, 
#                                                          
#polygon of RLP with buffer of 200m, source: https://opendata-esri-de.opendata.arcgis.com/datasets/esri-de-content::landesgrenze-rlp/data


# 1 - summer scene
prepSentinel(resolution = 20,
             folderNames = list.files(envrmt$summer, full.names = TRUE),
             fileNames = list.files(envrmt$summer, full.names = FALSE),
             outputPath = envrmt$summer)

# 1 - winter scene
prepSentinel(resolution = 20,
             folderNames = list.files(envrmt$winter, full.names = TRUE),
             fileNames = list.files(envrmt$winter, full.names = FALSE),
             outputPath = envrmt$winter)



summer = merge_crop_raster(listOfFiles = list.files(envrmt$summer, pattern = glob2rx("*.grd"), full.names = TRUE),
                           border = read_sf("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/Landesgrenze_RLP/Landesgrenze_RLP.shp"),
                           borderCrs = TRUE,
                           buffer = 200)

# write raster

winter = merge_crop_raster(listOfFiles = list.files(envrmt$winter, pattern = glob2rx("*.grd"), full.names = TRUE),
                           border = read_sf("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/Landesgrenze_RLP/Landesgrenze_RLP.shp"),
                           borderCrs = TRUE,
                           buffer = 200)


# write raster



# 2. Hansendaten
#-----------------------------






# 3. Waldeinrichtungsdaten
# 4. 


# # load tree cover tiles for RLP year 2000 
treeCover2000South <- raster::brick(file.path(envrmt$path_hansen, "Hansen_GFC-2018-v1.6_treecover2000_50N_000E.tif"))
treeCover2000North <- raster::brick(file.path(envrmt$path_hansen, "Hansen_GFC-2018-v1.6_treecover2000_60N_000E.tif"))


# 3 - forest inventory data
#----------------
# input
#load forest management data
wefl_UTM_BAZ <- sf::read_sf("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/Exp_Shape_Wefl_UTM/wefl_UTM_BAZ.shp")
forestLoss <- terra::rast("C:/Users/Lisa Bald/Uni_Marburg/Waldmodellierung/data/hansen/lossYear2018RLP.tif")
identicalCrs = FALSE
library(tidyverse)
library(terra)
treeSpeciesPurity = 80


sf::write_sf(wefl_WGS84_BAZ_5Loss, file.path(envrmt$path_Exp_Shape_Wefl_UTM, "wefl_WGS84_BAZ_5Loss.shp"))
wefl_WGS84_BAZ_5Loss <- sf::read_sf(file.path(envrmt$path_Exp_Shape_Wefl_UTM, "wefl_WGS84_BAZ_5Loss.shp"))


